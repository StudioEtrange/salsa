# SERVICE LIFECYCLE -----------


# start a service or all services 
# if no service specified will start all service (by starting docker compose service "tango")
# OPTIONS
#		NO_EXEC_PLUGINS do not run attached plugins
#		BUILD	build image before starting
# TODO up --no-recreate ? == each time compose file is modified the container is recreated
#							 maybe we want this, because we start or restart a service after modifying a configuration
# 	if there are existing containers for a service, 
#	and the service’s configuration or image was changed after the container’s creation,
#	docker-compose up picks up the changes by stopping and recreating the containers 
#	(preserving mounted volumes). To prevent Compose from picking up changes, use the --no-recreate flag.
__service_up() {
	local __service="$1"
	local __opt="$2"

	local __build=
	local __no_exec_plugins=
	for o in ${__opt}; do
		[ "$o" = "BUILD" ] &&  __build="--build"
		[ "$o" = "NO_EXEC_PLUGINS" ] && __no_exec_plugins="1"
	done

	docker-compose up -d $__build ${__service:-tango}

	if [ "${__service}" = "" ]; then
		[ ! "$__no_exec_plugins" = "1" ] && __exec_auto_plugin_service_active_all
		docker-compose logs service_init
	else
		[ ! "$__no_exec_plugins" = "1" ] && __exec_auto_plugin_all_by_service ${__service}
		docker-compose logs ${__service}
	fi

}

# OPTIONS
#	NO_DELETE do not delete containers just stop them
__service_down_all() {
	local __opt="$1"

	local __no_delete=
	for o in ${__opt}; do
		[ "$o" = "NO_DELETE" ] &&  __no_delete="1"
	done

	if [ "${TANGO_INSTANCE_MODE}" = "shared" ]; then 
		if [ ! "${ALL}" = "1" ]; then
			# test if network already exist and set it as 'external' to not erase it
			if [ ! -z $(docker network ls --filter name=^${TANGO_APP_NETWORK_NAME}$ --format="{{ .Name }}") ] ; then 
				[ "${TANGO_ALTER_GENERATED_FILES}" = "ON" ] && __set_network_as_external "default" "${TANGO_APP_NETWORK_NAME}"
			fi
		fi

		if [ ! "${ALL}" = "1" ]; then
			# only non shared service
			docker stop $(docker ps -q $(__container_filter 'NON_STOPPED LIST_NAMES '${TANGO_APP_NAME}'_.*'))
			[ ! "${__no_delete}" = "1" ] && docker rm $(docker ps -q $(__container_filter 'ONLY_STOPPED LIST_NAMES '${TANGO_APP_NAME}'_.*'))
		else
			# only shared and non shared service
			if [ "${__no_delete}" = "1" ]; then
				docker stop $(docker ps -q $(__container_filter 'NON_STOPPED LIST_NAMES '${TANGO_APP_NAME}'_.* '${TANGO_INSTANCE_NAME}'_.*'))
			else
				docker-compose down -v
			fi
		fi
	else
		if [ "${__no_delete}" = "1" ]; then
			docker stop $(docker ps -q $(__container_filter 'NON_STOPPED LIST_NAMES '${TANGO_APP_NAME}'_.* '${TANGO_INSTANCE_NAME}'_.*'))
		else
			docker-compose down -v
		fi
	fi
}

# OPTIONS
#	NO_DELETE do not delete container just stop it
__service_down() {
	local __service="$1"
	local __opt="$2"

	local __no_delete=
	for o in ${__opt}; do
		[ "$o" = "NO_DELETE" ] &&  __no_delete="1"
	done

	docker-compose stop "${__service}"
	[ ! "${__no_delete}" = "1" ] && docker-compose rm -f -v "${__service}"
}

# MANAGE ENV VARIABLES AND FILES GENERATION -----------------

# load all declared variables (including associative arrays)
__load_env_vars() {
	
	# preserve some current variables
	local __d="$DEBUG"
	local __t1="$TANGO_LOG_LEVEL"
	local __t2="$TANGO_LOG_STATE"

	. "${GENERATED_ENV_FILE_FOR_BASH}"
	__load_env_associative_arrays

	export DEBUG="$__d"
	export TANGO_LOG_LEVEL="$__t1"
	export TANGO_LOG_STATE="$__t2"
	
}


# load all associative arrays
# https://stackoverflow.com/a/59157715
__load_env_associative_arrays() {
	for __array in ${ASSOCIATIVE_ARRAY_LIST}; do
		__str="declare -A $__array=\"\$__array\""
		eval $__str
	done 
}

# update env files with current declared variables in VARIABLES_LIST
__update_env_files() {
	local __text="$1"
	echo "# ------ UPDATE : update_env_files : $(date) -- ${__text}" >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"
	echo "# ------ UPDATE : update_env_files : $(date) -- ${__text}" >> "${GENERATED_ENV_FILE_FOR_BASH}"
	for __variable in ${VARIABLES_LIST}; do
		[ -z ${!__variable+x} ] || echo "${__variable}=${!__variable}" >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"
		# NOTE : we need to export variables because some software like ansible need to access them
		# 		 we export variables only when update file (__update_env_files) not when file is created (__create_env_for_bash) because it easier
		[ -z ${!__variable+x} ] || echo "export ${__variable}=\"$(echo ${!__variable} | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g')\"" >> "${GENERATED_ENV_FILE_FOR_BASH}"	
	done

	# store associative arrays
	# to load stored associative arrays from compose env file see __load_env_associative_arrays
	# https://stackoverflow.com/a/59157715
	for __array in ${ASSOCIATIVE_ARRAY_LIST}; do
		# note : use this to store array name and get its length
		declare -n array_name="$__array"
		if [ ${#array_name[@]} -gt 0 ]; then
			__content="$(printf "%q" "$(declare -p $__array | cut -d= -f2-)")"
			echo "${__array}=${__content}" >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"
			declare -p $__array >> "${GENERATED_ENV_FILE_FOR_BASH}"
		fi
	done

	
}

# extract declared variable names from various env files (tango, app and user env files)
__init_declared_variable_names() {
	# reset global variables values
	export VARIABLES_LIST=""
	export ASSOCIATIVE_ARRAY_LIST=""

	# init VARIABLES_LIST values
	[ -f "${TANGO_ENV_FILE}" ] && VARIABLES_LIST="$(sed -e '/^[[:space:]]*$/d' -e '/^[#]\+.*$/d' -e 's/^\([^=+]*\)+\?=\(.*\)$/\1/g' "${TANGO_ENV_FILE}")"
	[ -f "${TANGO_APP_ENV_FILE}" ] && VARIABLES_LIST="${VARIABLES_LIST} $(sed -e '/^[[:space:]]*$/d' -e '/^[#]\+.*$/d' -e 's/^\([^=+]*\)+\?=\(.*\)$/\1/g' "${TANGO_APP_ENV_FILE}")"
	[ -f "${TANGO_USER_ENV_FILE}" ] && VARIABLES_LIST="${VARIABLES_LIST} $(sed -e '/^[[:space:]]*$/d' -e '/^[#]\+.*$/d' -e 's/^\([^=+]*\)+\?=\(.*\)$/\1/g' "${TANGO_USER_ENV_FILE}")"

	VARIABLES_LIST="$($STELLA_API list_filter_duplicate "${VARIABLES_LIST}")"

}

# add new variables names from modules env file
__add_modules_declared_variable_names() {
				
	# add modules env file
	for s in ${TANGO_SERVICES_MODULES}; do
		if [ -f "${TANGO_APP_MODULES_ROOT}/${s}.env" ]; then
			VARIABLES_LIST="${VARIABLES_LIST} $(sed -e '/^[[:space:]]*$/d' -e '/^[#]\+.*$/d' -e 's/^\([^=+]*\)+\?=\(.*\)$/\1/g' "${TANGO_APP_MODULES_ROOT}/${s}.env")"
		else
			[ -f "${TANGO_MODULES_ROOT}/${s}.env" ] && VARIABLES_LIST="${VARIABLES_LIST} $(sed -e '/^[[:space:]]*$/d' -e '/^[#]\+.*$/d' -e 's/^\([^=+]*\)+\?=\(.*\)$/\1/g' "${TANGO_MODULES_ROOT}/${s}.env")"
		fi
	done
	VARIABLES_LIST="$($STELLA_API list_filter_duplicate "${VARIABLES_LIST}")"
}




# add variables to variables list to be stored in env files
__add_declared_variables() {
	VARIABLES_LIST="${VARIABLES_LIST} $1"
}

# add associative array to arrays list to be stored in env files
__add_declared_associative_array() {
	ASSOCIATIVE_ARRAY_LIST="${ASSOCIATIVE_ARRAY_LIST} ${1}"
}



# generate an env file from various env files (tango, app, modules and user env files) to be used as env-file in environment section of docker compose file (GENERATED_ENV_FILE_FOR_COMPOSE)
__create_env_for_docker_compose() {
	echo "# ------ CREATE : create_env_for_docker_compose : $(date)" > "${GENERATED_ENV_FILE_FOR_COMPOSE}"

	# add default tango env file
	cat <(echo \# --- PART FROM default tango env file ${TANGO_ENV_FILE}) <(echo) <(echo) "${TANGO_ENV_FILE}" <(echo) >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"
	
	# add app env file
	[ -f "${TANGO_APP_ENV_FILE}" ] &&  cat <(echo \# --- PART FROM app env file ${TANGO_APP_ENV_FILE}) <(echo) <(echo) "${TANGO_APP_ENV_FILE}" <(echo) >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"

	# add modules env file
	for s in ${TANGO_SERVICES_MODULES}; do
		# app modules overrides tango modules
		if [ -f "${TANGO_APP_MODULES_ROOT}/${s}.env" ]; then
			cat <(echo \# --- PART FROM modules env file ${TANGO_APP_MODULES_ROOT}/${s}.env) <(echo) <(echo) "${TANGO_APP_MODULES_ROOT}/${s}.env" <(echo) >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"
		else
			[ -f "${TANGO_MODULES_ROOT}/${s}.env" ] && cat <(echo \# --- PART FROM modules env file ${TANGO_MODULES_ROOT}/${s}.env) <(echo) <(echo) "${TANGO_MODULES_ROOT}/${s}.env" <(echo) >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"
		fi
	done

	# add user env file
	[ -f "${TANGO_USER_ENV_FILE}" ] && cat <(echo \# --- PART FROM user env file ${TANGO_USER_ENV_FILE}) <(echo) <(echo) "${TANGO_USER_ENV_FILE}" <(echo) >> "${GENERATED_ENV_FILE_FOR_COMPOSE}"

	__parse_env_file "${GENERATED_ENV_FILE_FOR_COMPOSE}"
}

# generate an env file from various env files (tango, app, modules and user env files) to be sourced (GENERATED_ENV_FILE_FOR_BASH)
__create_env_for_bash() {
	echo "# ------ CREATE : create_env_for_bash : $(date)" > "${GENERATED_ENV_FILE_FOR_BASH}"

	# add default tango env file
	cat <(echo \# --- PART FROM default tango env file ${TANGO_ENV_FILE}) <(echo) <(echo) "${TANGO_ENV_FILE}" <(echo) >> "${GENERATED_ENV_FILE_FOR_BASH}"
	
	# add app env file
	[ -f "${TANGO_APP_ENV_FILE}" ] &&  cat <(echo \# --- PART FROM app env file ${TANGO_APP_ENV_FILE}) <(echo) <(echo) "${TANGO_APP_ENV_FILE}" <(echo) >> "${GENERATED_ENV_FILE_FOR_BASH}"

	# add modules env file
	for s in ${TANGO_SERVICES_MODULES}; do
		# app modules overrides tango modules
		if [ -f "${TANGO_APP_MODULES_ROOT}/${s}.env" ]; then
			cat <(echo \# --- PART FROM modules env file ${TANGO_APP_MODULES_ROOT}/${s}.env) <(echo) <(echo) "${TANGO_APP_MODULES_ROOT}/${s}.env" <(echo) >> "${GENERATED_ENV_FILE_FOR_BASH}"
		else
			[ -f "${TANGO_MODULES_ROOT}/${s}.env" ] && cat <(echo \# --- PART FROM modules env file ${TANGO_MODULES_ROOT}/${s}.env) <(echo) <(echo) "${TANGO_MODULES_ROOT}/${s}.env" <(echo) >> "${GENERATED_ENV_FILE_FOR_BASH}"
		fi
	done

	# add user env file
	[ -f "${TANGO_USER_ENV_FILE}" ] && cat <(echo \# --- PART FROM user env file ${TANGO_USER_ENV_FILE}) <(echo) <(echo) "${TANGO_USER_ENV_FILE}" <(echo) >> "${GENERATED_ENV_FILE_FOR_BASH}"

	__parse_env_file "${GENERATED_ENV_FILE_FOR_BASH}"

	# add quote for variable bash support
	sed -i -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g' "${GENERATED_ENV_FILE_FOR_BASH}"
	sed -i 's/^\([a-zA-Z0-9_-]*\)=\(.*\)$/\1=\"\2\"/g' "${GENERATED_ENV_FILE_FOR_BASH}"
}



# remove commentary and manage cumulative assignation with +=
__parse_env_file() {
	local _file="$1"

	local _temp=$(mktmp)

	awk -F= '
	BEGIN {
	}

	# catch +=
	/^[^=#]*\+=/ {
		key=substr($1, 1, length($1)-1);
		if (arr[key]) arr[key]=arr[key] " " $2;
		else arr[key]=$2;
		print key"="arr[key];
		next;
	}

	# catch =
	/^[^=#]*=/ {
		arr[$1]=$2;
		print $0;
		next;
	}

	/.*/ {
		print $0;
		next;
	}
	
	END {
	}
	' "${_file}" > "${_temp}"
	cat "${_temp}" > "${_file}"
	rm -f "${_temp}"
	
	__parse_env_file2 "$1"
}

# manage {{var}} substitution
# TODO work only non recursive
#	This do not work : 
#	A=1
#	B={{A}}
#	C={{B}}
__parse_env_file2() {
	local _file="$1"

	local _temp=$(mktmp)

	awk -F= '
	/^[^=#]*=/ {
		if (FNR==NR) {
		
			arr[$1]=$2;
			next;
		}
	}
	/.*/ {
		if (FNR==NR) {
			next;
		}
	}

	{
		for (a in arr) gsub("{{"a"}}", arr[a]);
		print;
	} 

	' "${_file}" "${_file}" > "${_temp}"
	cat "${_temp}" > "${_file}"
	rm -f "${_temp}"
	
}



# generate docker compose file
__create_docker_compose_file() {
	rm -f "${GENERATED_DOCKER_COMPOSE_FILE}"

	# concatenate compose files starting with tango compose file
	# NOTE : do not explode anchors here, we need to keep anchor &default-vpn, because we add vpn sections later and we need &default-vpn still exists
	cp -f "${TANGO_COMPOSE_FILE}" "${GENERATED_DOCKER_COMPOSE_FILE}"

	
	# manage traefik entrypoint
	__add_entrypoints_all


	# app compose file
	[ -f "${TANGO_APP_COMPOSE_FILE}" ] && yq m -i -a=append -- "${GENERATED_DOCKER_COMPOSE_FILE}" <(yq r --explodeAnchors "${TANGO_APP_COMPOSE_FILE}")

	# user compose file
	[ -f "${TANGO_USER_COMPOSE_FILE}" ] && yq m -i -a=append -- "${GENERATED_DOCKER_COMPOSE_FILE}" <(yq r --explodeAnchors "${TANGO_USER_COMPOSE_FILE}")


	# define network area
	__set_network_area_all


	__set_module_all
	__set_active_services_all
	__set_time_all
	
	# attach all services to entrypoints
	__set_entrypoints_service_all
	# attach all subservices to entrypoints
	__set_entrypoints_subservice_all

	__set_routers_info_service_all
	__set_priority_router_all

	__set_redirect_https_service_all
	
	# set priority for error router after to override default setted values for any service
	__set_error_engine
	__add_service_direct_port_access_all
	__add_gpu_all
	__add_volume_artefact_all
	__add_volume_pool_and_plugins_data_all
	__add_generated_env_file_all
	__set_letsencrypt_service_all
	__create_vpn_all

	# do this after other compose modification 	
	# because it remove some network definition
	# and because some methods below add service to VPN_x_SERVICES
	__set_vpn_service_all
}


# translate all relative path to absolute
# translate all declared variables which end with _PATH
__translate_all_path() {


	for __variable in ${VARIABLES_LIST}; do
		case ${__variable} in
			*_PATH) [ ! "${!__variable}" = "" ] && export ${__variable}="$($STELLA_API rel_to_abs_path "${!__variable}" "${TANGO_APP_ROOT}")"
			;;
		esac
	done


	if [ ! "${TANGO_ARTEFACT_FOLDERS}" = "" ]; then
		__tmp=
		for f in ${TANGO_ARTEFACT_FOLDERS}; do
			f="$($STELLA_API rel_to_abs_path "${f}" "${TANGO_APP_ROOT}")"
			__tmp="${__tmp} ${f}"
		done
		export TANGO_ARTEFACT_FOLDERS="$($STELLA_API trim "${__tmp}")"
	fi

	if [ ! "${TANGO_CERT_FILES}" = "" ]; then
		__tmp=
		for f in ${TANGO_CERT_FILES}; do
			f="$($STELLA_API rel_to_abs_path "${f}" "${TANGO_APP_ROOT}")"
			__tmp="${__tmp} ${f}"
		done
		export TANGO_CERT_FILES="$($STELLA_API trim "${__tmp}")"
	fi

	if [ ! "${TANGO_KEY_FILES}" = "" ]; then
		__tmp=
		for f in ${TANGO_KEY_FILES}; do
			f="$($STELLA_API rel_to_abs_path "${f}" "${TANGO_APP_ROOT}")"
			__tmp="${__tmp} ${f}"
		done
		export TANGO_KEY_FILES="$($STELLA_API trim "${__tmp}")"
	fi
}




# MANAGE FEATURES FOR ALL CONTAINTERS -----------------

# declare all active service as "tango" service depdenciess in compose file
__set_active_services_all() {
	for s in ${TANGO_SERVICES_ACTIVE}; do
		__check_docker_compose_service_exist "${s}" && __add_service_dependency "tango" "${s}" || __tango_log "WARN" "tango" "unknow service ${s} declared in TANGO_SERVICES_ACTIVE"
	done
}

__set_vpn_service_all() {

	local _tmp=
	local _id=
	for v in ${VPN_SERVICES_LIST}; do
		_tmp="${v^^}_SERVICES"
		_id="${v/#*_}"
		for s in ${!_tmp}; do
			__check_docker_compose_service_exist "${s}" && __set_vpn_service "${s}" "${_id}" "${v}" || __tango_log "WARN" "tango" "unknow service ${s} declared in ${_tmp}"
		done

	done
}



__create_vpn_all() {

	__add_declared_variables "VPN_SERVICES_LIST"
	# NOTE : +4/-4 is for bybass 'VPN_'
	for _id in $(compgen -A variable | awk 'match($0,/VPN_[0-9]+/) {print substr($0,RSTART+4,RLENGTH-4)}' | sort | uniq); do
		__create_vpn ${_id}
		__add_service_dependency "vpn" "vpn_${_id}"
		export VPN_SERVICES_LIST="${VPN_SERVICES_LIST} vpn_${_id}"
	done

}



__set_certificates_all() {
	
	# empty file
	echo -n "" > "${GENERATED_TLS_FILE_PATH}"

	local i=0
	for p in ${TANGO_CERT_FILES}; do
		yq w -i -- "${GENERATED_TLS_FILE_PATH}" "tls.certificates[$i].certFile" "${p}"
		__add_volume_mapping_service "traefik" "${p}:${p}"
		(( i++ ))
	done

	i=0
	for k in ${TANGO_KEY_FILES}; do
		yq w -i -- "${GENERATED_TLS_FILE_PATH}" "tls.certificates[$i].keyFile" "${k}"
		__add_volume_mapping_service "traefik" "${k}:${k}"
		(( i++ ))
	done
}



# add a artefact_xxx named volume defintion
# attach this artefact_xxx named volume to a /$TANGO_ARTEFACT_MOUNT_POINT/xxxx folder to each service listed in TANGO_ARTEFACT_SERVICES
__add_volume_artefact_all() {
	for f in ${TANGO_ARTEFACT_FOLDERS}; do
		f="$($STELLA_API rel_to_abs_path "${f}" "${TANGO_APP_ROOT}")"
		target="$(basename "${f}")"
		if [ -f "${f}" ]; then 
			__tango_log "WARN" "tango" "[${f}] is a file, not mounted inside folder {${TANGO_ARTEFACT_MOUNT_POINT}}"
		else
			[ ! -d "${f}" ] && __tango_log "INFO" "tango" "[${f}] is not an existing directory and will be auto created."
			__name="$($STELLA_API md5 "${f}")"
			__add_volume_local_definition "artefact_${__name}" "${f}"
			for s in $TANGO_ARTEFACT_SERVICES; do
				__check_docker_compose_service_exist "${s}" && __add_volume_mapping_service "${s}" "artefact_${__name}:${TANGO_ARTEFACT_MOUNT_POINT}/${target}"
				# NOTE : do not print WARN because a warn is printed for each artefact folder for each undefined services
				#	|| echo "** WARN : unknow ${s} service declared in TANGO_ARTEFACT_SERVICES"
				
			done
			__tango_log "DEBUG" "tango" "[${f}] will be mapped to {${TANGO_ARTEFACT_MOUNT_POINT}/${target}}"
		fi
	done
}

# attach generated env compose file to services
__add_generated_env_file_all() {
	for s in ${TANGO_SERVICES_ACTIVE}; do
		__add_generated_env_file ${s}
	done
}

# add pool volume and plugins_data to each service
__add_volume_pool_and_plugins_data_all() {

	# add default pool folder
	for s in ${TANGO_SERVICES_ACTIVE}; do
		__add_volume_mapping_service "${s}" "${TANGO_ROOT}/pool:/pool/tango"
		__add_volume_mapping_service "${s}" "${PLUGINS_DATA_PATH}:/plugins_data"
	done
	__add_volume_mapping_service "service_info" "${TANGO_ROOT}/pool:/pool/tango"
	__add_volume_mapping_service "service_info" "${PLUGINS_DATA_PATH}:/plugins_data"
	__add_volume_mapping_service "service_init" "${TANGO_ROOT}/pool:/pool/tango"
	__add_volume_mapping_service "service_init" "${PLUGINS_DATA_PATH}:/plugins_data"

	# add pool app folder if it exists 
	if [ ! "${TANGO_NOT_IN_APP}" = "1" ]; then
		if [ -d "${TANGO_APP_ROOT}/pool" ]; then
			for s in ${TANGO_SERVICES_ACTIVE}; do
				__add_volume_mapping_service "${s}" "${TANGO_APP_ROOT}/pool:/pool/${TANGO_APP_NAME}"
			done
			__add_volume_mapping_service "service_info" "${TANGO_APP_ROOT}/pool:/pool/${TANGO_APP_NAME}"
			__add_volume_mapping_service "service_init" "${TANGO_APP_ROOT}/pool:/pool/${TANGO_APP_NAME}"
		fi
	fi



}

# add gpu to all container that need its
# NVIDIA | INTEL_QUICKSYNC
__add_gpu_all() {
	for s in $(compgen -A variable | grep _GPU$); do
		gpu="${!s}"
		if [ ! "${gpu}" = "" ]; then
			service="${s%_GPU}"
			service="${service,,}"
			__check_docker_compose_service_exist "${service}" && __add_gpu "${service}" "${gpu}" || __tango_log "WARN" "tango" "unknow service ${service} declared in ${s}"
		fi
	done
}

# set timezone to containers which need it
__set_time_all() {

	for s in $TANGO_TIME_VOLUME_SERVICES; do
		__check_docker_compose_service_exist "${s}" && __add_volume_for_time "$s" || __tango_log "WARN" "tango" "unknow service ${s} declared in TANGO_TIME_VOLUME_SERVICES"
	done

	for s in $TANGO_TIME_VAR_TZ_SERVICES; do
		__check_docker_compose_service_exist "${s}" && __add_tz_var_for_time "$s" || __tango_log "WARN" "tango" "unknow service ${s} declared in TANGO_TIME_VAR_TZ_SERVICES"
	done

}



__set_letsencrypt_service_all() {

	
	case ${LETS_ENCRYPT} in
		enable|debug )
			for serv in ${LETS_ENCRYPT_SERVICES}; do
				__add_letsencrypt_service "${serv}"
			done

			case ${LETS_ENCRYPT_CHALLENGE} in
				HTTP )
					yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--certificatesresolvers.tango.acme.httpchallenge=true"
					yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--certificatesresolvers.tango.acme.httpchallenge.entrypoint=entry_main_http"
				;;
				DNS )
					yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--certificatesresolvers.tango.acme.dnschallenge=true"
					yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--certificatesresolvers.tango.acme.dnschallenge.provider=${LETS_ENCRYPT_CHALLENGE_DNS_PROVIDER}"
				;;
			esac
			
		;;
	esac

	# set letsencrypt debug server if needed
	[ "${LETS_ENCRYPT}" = "debug" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--certificatesresolvers.tango.acme.caserver=${LETS_ENCRYPT_SERVER_DEBUG}"
}



__set_routers_info_service_all() {

	
	local area
	local name
	local proto
	local internal_port
	local secure_port
	local __service
	local __port
	local __entrypoints=
	local __entrypoint_default=
	local __var=
	local __subdomain=
	local __hostname=
	local __subservice_flag=
	local __address=
	local __uri=
	local __parent=
	local __router_list=
	
	__tango_log "DEBUG" "tango" "set_routers_info_service_all : setting routers information (port, subdomain, hostname, address, uri)"

	for __service in ${TANGO_SERVICES_AVAILABLE} SUBSERVICES_DELIMITER ${TANGO_SUBSERVICES_ROUTER}; do
		
		__subdomain=
		__hostname=
		__address=
		__port=
		__uri=

		if [ "${__service}" = "SUBSERVICES_DELIMITER" ]; then
			# we iter inside subservice list
			__subservice_flag="1"
			continue
		fi

		if [ "${__subservice_flag}" = "1" ]; then
			__parent="$(__get_subservice_parent "${__service}")"
			__router_list="${__parent^^}_ROUTERS_LIST"
			__router_list="${!__router_list} ${__service}"
			eval "export ${__parent^^}_ROUTERS_LIST=\"${__router_list}\""
			__add_declared_variables "${__parent^^}_ROUTERS_LIST"
		else
			eval "export ${__service^^}_ROUTERS_LIST=\"${__service}\""
			__add_declared_variables "${__service^^}_ROUTERS_LIST"
		fi


		__entrypoints="${__service^^}_ENTRYPOINTS"
		__entrypoints="${!__entrypoints}"
		__entrypoint_default="${__service^^}_ENTRYPOINT_DEFAULT"
		__entrypoint_default="${!__entrypoint_default}"


		if [ ! "${__entrypoints}" = "" ]; then
			__var="${__service^^}_SUBDOMAIN"
			if [ -z ${!__var+x} ]; then
				if [ "${__subservice_flag}" = "1" ]; then
					__subdomain="$(__get_subservice_parent "${__service}")."
				else
					# by default each router of a service have the service name as subdomin name value
					__subdomain="${__service}."
				fi
				eval "export ${__service^^}_SUBDOMAIN=${__subdomain}"
				__add_declared_variables "${__service^^}_SUBDOMAIN"
			else
				__subdomain="${!__var}"
			fi

			[ "${TANGO_DOMAIN}" = '.*' ] && __hostname="${__subdomain}" || __hostname="${__subdomain}${TANGO_DOMAIN}"
			eval "export ${__service^^}_HOSTNAME=${__hostname}"
			__add_declared_variables "${__service^^}_HOSTNAME"

			__tango_log "DEBUG" "tango" "service : ${__service} - entrypoints : ${__entrypoints} - subdomain : ${__subdomain} - hostname : ${__hostname}"
		else
			__tango_log "DEBUG" "tango" "service : ${__service} is not attached to any entrypoint"
		fi

		for e in ${__entrypoints}; do
			area="$(__get_network_area_name_from_entrypoint "${e}")"

			__port="NETWORK_PORT_${area^^}"
			__port="${!__port}"
			eval "export ${__service^^}_PORT_${area^^}=${__port}"
			__add_declared_variables "${__service^^}_PORT_${area^^}"

			[ "${__port}" = "" ] && __address="${__hostname}" || __address="${__hostname}:${__port}"
			eval "export ${__service^^}_ADDRESS_${area^^}=${__address}"
			__add_declared_variables "${__service^^}_ADDRESS_${area^^}"

			proto="NETWORK_SERVICES_AREA_${area^^}_PROTO"
			proto="${!proto}"
			case $proto in
				http ) __uri="http://${__address}" ;;
				tcp ) __uri="tcp://${__address}" ;;
				udp ) __uri="tcp://${__address}" ;;
				* )	__uri="unknow://${__address}" ;;
			esac
			eval "export ${__service^^}_URI_${area^^}=${__uri}"
			__add_declared_variables "${__service^^}_URI_${area^^}"

			if [ "$e" = "${__entrypoint_default}" ]; then
				eval "export ${__service^^}_URI_DEFAULT=${__uri}"
				__add_declared_variables "${__service^^}_URI_DEFAULT"
			fi

			secure_port="NETWORK_SERVICES_AREA_${area^^}_INTERNAL_SECURE_PORT"
			secure_port="${!secure_port}"
			if [ ! "${secure_port}" = "" ] ; then
				__port="NETWORK_PORT_${area^^}_SECURE"
				__port="${!__port}"
				eval "export ${__service^^}_PORT_${area^^}_SECURE=${__port}"
				__add_declared_variables "${__service^^}_PORT_${area^^}_SECURE"

				[ "${__port}" = "" ] && __address="${__hostname}" || __address="${__hostname}:${__port}"
				eval "export ${__service^^}_ADDRESS_${area^^}_SECURE=${__address}"
				__add_declared_variables "${__service^^}_ADDRESS_${area^^}_SECURE"
				
				case $proto in
					http ) __uri="https://${__address}" ;;
					tcp ) __uri="tcp://${__address}" ;;
					udp ) __uri="tcp://${__address}" ;;
					* )	__uri="unknow://${__address}" ;;
				esac
				eval "export ${__service^^}_URI_${area^^}_SECURE=${__uri}"
				__add_declared_variables "${__service^^}_URI_${area^^}_SECURE"

				if [ "$e" = "${__entrypoint_default}" ]; then
					eval "export ${__service^^}_URI_DEFAULT_SECURE=${__uri}"
					__add_declared_variables "${__service^^}_URI_DEFAULT_SECURE"
				fi
			fi
			

		done

	done
}

# Define network areas into compose file
# Each network area have traefik entrypoint with a name, a protocol an internal port and an optional associated entrypoint
# The associated entrypoint have same name with postfix _secure is mainly used to declare an alternative HTTPS entrypoint to a HTTP entrypoint
# NETWORK_SERVICES_AREA_LIST=main|tcp|80|443 secondary|tcp|8000|8443 test|udp|41000 
__add_entrypoints_all() {
	
	local __area_main_done=
	for area in ${NETWORK_SERVICES_AREA_LIST}; do
		IFS="|" read -r name proto internal_port secure_port <<<$(echo ${area})
		__add_entrypoint "$name" "$proto" "$internal_port" "$secure_port"
		[ "$name" = "main" ] && __area_main_done=1
		__add_declared_variables "NETWORK_SERVICES_AREA_${name^^}"
	done

	# add by default the definition of main network area if not defined in list
	if [ ! "$__area_main_done" = "1" ]; then
		__add_entrypoint "main" "http" "80" "443"
		NETWORK_SERVICES_AREA_LIST="main|http|80|443 $NETWORK_SERVICES_AREA_LIST"
		__add_declared_variables "NETWORK_SERVICES_AREA_MAIN"
	fi

}

# __add_entrypoint "test" "udp" "41000"
# 		"--entrypoints.entry_test_udp=true"
#	    "--entrypoints.entry_test_udp.address=:41000/udp"
# __add_entrypoint "second" "tcp" "8000"
# 		"--entrypoints.entry_main_tcp=true"
#	    "--entrypoints.entry_main_tcp.address=:8000/tcp"
# __add_entrypoint "main" "http" "80" "443"
# 		"--entrypoints.entry_main_http=true"
#	    "--entrypoints.entry_main_http.address=:80/tcp"
# 		"--entrypoints.entry_main_http_secure=true"
#	    "--entrypoints.entry_main_http_secure.address=:443/tcp"
__add_entrypoint() {
	local __name="$1"
	local __proto="$2"
	local __internal_port="$3"
	local __assiocated_entrypoint="$4" # optional
	
	local __real_proto
	
	case ${__proto} in
		http|tcp )
			__real_proto="tcp"
		;;
		udp )
			__real_proto="udp"
		;;
	esac

	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--entrypoints.entry_${__name}_${__proto}=true"
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--entrypoints.entry_${__name}_${__proto}.address=:${__internal_port}/${__real_proto}"
	export TRAEFIK_ENTRYPOINTS_LIST="$TRAEFIK_ENTRYPOINTS_LIST entry_${__name}_${__proto}"
	# add port mapping to traefik
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.ports[+]" "\${NETWORK_PORT_${__name^^}}:$__internal_port/${__real_proto}"
	__add_declared_variables "NETWORK_PORT_${__name^^}"
	
	case ${__proto} in
		http )
			if [ ! "$__assiocated_entrypoint" = "" ]; then
				yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--entrypoints.entry_${__name}_${__proto}_secure=true"
				yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.command[+]" "--entrypoints.entry_${__name}_${__proto}_secure.address=:${__assiocated_entrypoint}/${__real_proto}"
				export TRAEFIK_ENTRYPOINTS_LIST="$TRAEFIK_ENTRYPOINTS_LIST entry_${__name}_${__proto}_secure"
				# add port mapping to traefik
				yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.ports[+]" "\${NETWORK_PORT_${__name^^}_SECURE}:$__assiocated_entrypoint/${__real_proto}"
				__add_declared_variables "NETWORK_PORT_${__name^^}_SECURE"
			fi
		;;
	esac

	TRAEFIK_ENTRYPOINTS_LIST="$($STELLA_API trim ${TRAEFIK_ENTRYPOINTS_LIST})"
	TRAEFIK_ENTRYPOINTS_LIST="${TRAEFIK_ENTRYPOINTS_LIST// /,}"
	__add_declared_variables "TRAEFIK_ENTRYPOINTS_LIST"
	
}


__set_network_area_all() {
	
	for area in ${NETWORK_SERVICES_AREA_LIST}; do
		IFS="|" read -r name proto internal_port secure_port <<<$(echo ${area})

		eval "export NETWORK_SERVICES_AREA_${name^^}_PROTO=${proto}"
		__add_declared_variables "NETWORK_SERVICES_AREA_${name^^}_PROTO"
		eval "export NETWORK_SERVICES_AREA_${name^^}_INTERNAL_PORT=${internal_port}"
		__add_declared_variables "NETWORK_SERVICES_AREA_${name^^}_INTERNAL_PORT"
		eval "export NETWORK_SERVICES_AREA_${name^^}_INTERNAL_SECURE_PORT=${secure_port}"
		__add_declared_variables "NETWORK_SERVICES_AREA_${name^^}_INTERNAL_SECURE_PORT"
	done

	
}

# attach all services to entrypoint
__set_entrypoints_service_all() {

	local var

	for area in ${NETWORK_SERVICES_AREA_LIST}; do
		IFS="|" read -r name proto internal_port secure_port <<<$(echo ${area})

		var="NETWORK_SERVICES_AREA_${name^^}"

		# assign each declared service or subservice attached to this area
		for s in ${!var}; do
			__tango_log "DEBUG" "tango" "service : ${s} is attached to network area : ${name}"
			__set_entrypoint_service "${s}" "${name}"
		done
	done


}


# parse subservice list to attach each subservice to its parent entrypoint (if parents have an entrypoint and if not already attached)
# note : by default each subservice have the same entrypoint than its parent service
__set_entrypoints_subservice_all() {
	local var
	local parent
	local parent_entrypoints_list
	local parent_entrypoint_default

	for s in ${TANGO_SUBSERVICES_ROUTER}; do

		parent=$(__get_subservice_parent "$s")
		
		parent_entrypoints_list="${parent^^}_ENTRYPOINTS"
		parent_entrypoints_list="${!parent_entrypoints_list}"
		parent_entrypoint_default="${parent^^}_ENTRYPOINT_DEFAULT"
		parent_entrypoint_default="${!parent_entrypoint_default}"
		var="${s^^}_ENTRYPOINTS"
		# subservice not attached to an entrypoint so attached to the same as its parent
		if [ "${!var}" = "" ]; then
			if [ ! "${parent_entrypoints_list}" = "" ]; then
				eval "export ${var}=${parent_entrypoints_list}"
				__add_declared_variables "${var}"
				eval "export ${s^^}_ENTRYPOINT_DEFAULT=${parent_entrypoint_default}"
				__add_declared_variables "${s^^}_ENTRYPOINT_DEFAULT"
				__tango_log "DEBUG" "tango" "assign subservice : ${s}, child of service : ${parent}, to its parent entrypoints : ${parent_entrypoints_list}"
			fi
		else
			__tango_log "DEBUG" "tango" "subservice : ${s}, child of service : ${parent}, was already assigned to its own entrypoints : ${!var}"
		fi

		var="${s^^}_ENTRYPOINTS_SECURE"
		if [ "${!var}" = "" ]; then
			parent_entrypoints_list="${parent^^}_ENTRYPOINTS_SECURE"
			parent_entrypoints_list="${!parent_entrypoints_list}"
			parent_entrypoint_default="${parent^^}_ENTRYPOINT_DEFAULT_SECURE"
			parent_entrypoint_default="${!parent_entrypoint_default}"

			if [ ! "${parent_entrypoints_list}" = "" ]; then
				eval "export ${var}=${parent_entrypoints_list}"
				__add_declared_variables "${var}"

				__tango_log "DEBUG" "tango" "assign subservice : ${s}, child of service : ${parent}, to its parent secure entrypoints : ${parent_entrypoints_list}"
				
				eval "export ${s^^}_ENTRYPOINT_DEFAULT_SECURE=${parent_entrypoint_default}"
				__add_declared_variables "${s^^}_ENTRYPOINT_DEFAULT_SECURE"
			fi
		fi
	done
}

__set_priority_router_all() {
	
	local __default_priority=${ROUTER_PRIORITY_DEFAULT_VALUE}
	local __priority=

	local __current_parent=
	local __previous_parent
	local __current_offset=0
	
	# for each declared subservices
	for s in ${TANGO_SUBSERVICES_ROUTER}; do

		__current_parent="$(__get_subservice_parent "${s}")"
		if [ ! "${__current_parent}" = "" ]; then
			if [ "${__current_parent}" = "${__previous_parent}" ]; then
				# same parent service, get a priority bonus
				__priority=$(( __priority + ROUTER_PRIORITY_DEFAULT_STEP ))
				__set_priority_router "${s}" "${__priority}"
			else
				# set first surbservice of a parent service
				__priority=$(( __default_priority + ROUTER_PRIORITY_DEFAULT_STEP ))
				__set_priority_router "${s}" "${__priority}"
			fi
		fi
		__previous_parent="${__current_parent}"
	done


	
	# affect priority to other services
	for s in ${TANGO_SERVICES_AVAILABLE}; do
		__set_priority_router "${s}" "${__default_priority}"
	done
}


# HTTP to HTTPS redirect routers - catch all request and redirect to secure entrypoint with HTTPS scheme if it is not the case
# NOTE : we cannot use the method of set redirect middleware on each routers service because each service routers
#        may have two entrypoints and middlewares dont know from which entrypoint the request come.
#        So we use a global catch all router rule, using priority for exclude some services
# NOTE : a redirect middleware will be dynamicly attached on each of these http-catchall-web_* routers
__set_redirect_https_service_all() {
	case ${NETWORK_REDIRECT_HTTPS} in
		enable )
			# create catchall routers
			for area in ${NETWORK_SERVICES_AREA_LIST}; do
				IFS="|" read -r name proto internal_port secure_port <<<$(echo ${area})
				if [ "$proto" = "http" ]; then
					if [ ! "$secure_port" = "" ]; then
						# catch HTTP request on entry_xxx_tcp and entry_xxx_tcp_secure entrypoint
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}.entrypoints=entry_${name}_${proto},entry_${name}_${proto}_secure"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}.rule=HostRegexp(\`{host:.+}\`)"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}.priority=\${ROUTER_PRIORITY_HTTP_TO_HTTPS_VALUE}"
						# catch HTTPS request on entry_xxx_tcp only entrypoint (no need to catch HTTPS on entry_xxx_tcp_secure)
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}_secure.entrypoints=entry_${name}_${proto}"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}_secure.rule=HostRegexp(\`{host:.+}\`)"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}_secure.priority=\${ROUTER_PRIORITY_HTTP_TO_HTTPS_VALUE}"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}_secure.tls=true"
						
						# - "traefik.http.routers.http-catchall-entry_admin_tcp.entrypoints=entry_admin_tcp,entry_admin_tcp_secure"
						# - "traefik.http.routers.http-catchall-entry_admin_tcp.rule=HostRegexp(`{host:.+}`)"
						# - "traefik.http.routers.http-catchall-entry_admin_tcp.priority=${ROUTER_PRIORITY_HTTP_TO_HTTPS_VALUE}"

						# - "traefik.http.routers.http-catchall-entry_admin_tcp_secure.entrypoints=entry_admin_tcp"
						# - "traefik.http.routers.http-catchall-entry_admin_tcp_secure.rule=HostRegexp(`{host:.+}`)"
						# - "traefik.http.routers.http-catchall-entry_admin_tcp_secure.priority=${ROUTER_PRIORITY_HTTP_TO_HTTPS_VALUE}"
						# - "traefik.http.routers.http-catchall-entry_admin_tcp_secure.tls=true"
						
						# declare HTTP to HTTPS redirect middlewares
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.middlewares.redirect-entry_${name}_${proto}_secure.redirectscheme.scheme=https"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.middlewares.redirect-entry_${name}_${proto}_secure.redirectscheme.permanent=true"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.middlewares.redirect-entry_${name}_${proto}_secure.redirectscheme.port=\${NETWORK_PORT_${name^^}_SECURE}"
						
						# - "traefik.http.middlewares.redirect-entry_main_tcp_secure.redirectscheme.scheme=https"
						# - "traefik.http.middlewares.redirect-entry_main_tcp_secure.redirectscheme.permanent=true"
						# - "traefik.http.middlewares.redirect-entry_main_tcp_secure.redirectscheme.port=${NETWORK_PORT_MAIN_SECURE}"

						# add middleware to catchall routers
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}.middlewares=redirect-entry_${name}_${proto}_secure@docker"
						yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.traefik.labels[+]" "traefik.http.routers.http-catchall-entry_${name}_${proto}_secure.middlewares=redirect-entry_${name}_${proto}_secure@docker"	

						#   - traefik.http.routers.http-catchall-entry_main_tcp.middlewares=redirect-entry_main_tcp_secure@docker
						#   - traefik.http.routers.http-catchall-entry_main_tcp_secure.middlewares=redirect-entry_main_tcp_secure@docker
					fi
				fi
			done

			for s in ${NETWORK_SERVICES_REDIRECT_HTTPS}; do
				__set_redirect_https_service "${s}"
			done
		;;
		* )
		;;
	esac

	
}


__add_service_direct_port_access_all() {
	for s in $(compgen -A variable | grep _DIRECT_ACCESS_PORT$); do
		port="${!s}"
		if [ ! "${port}" = "" ]; then
			service="${s%_DIRECT_ACCESS_PORT}"
			service="${service,,}"
			
			if __check_docker_compose_service_exist "${service}"; then
				port_inside="$(yq r "${GENERATED_DOCKER_COMPOSE_FILE}" services.$service.expose[0])"
				if [ ! "${port_inside}" = "" ]; then
					__tango_log "INFO" "tango" "Activate direct access to $service : mapping $port to $port_inside"
					yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.$service.ports[+]" "$port:$port_inside"
				else
					__tango_log "WARN" "tango" "cannot activate direct access to $service through $port : Unknown inside port to map to. Inside port must be declared as first port in expose section."
				fi
			else
				__tango_log "WARN" "tango" "unknow service ${service} declared in ${s}"
			fi
		fi
	done
}

# ITEMS MANAGEMENT (an item is a module or a plugin) -----------------------------------------

__set_module_all() {
	local __array_list_names=( ${TANGO_SERVICES_MODULES} )
	local __array_list_full=( ${TANGO_SERVICES_MODULES_FULL} )

	for index in ${!__array_list_names[*]}; do
		__set_module "${__array_list_full[$index]}"
	done
}

__set_module() {
	local __module="$1"

	__tango_log "DEBUG" "tango" "set_module : process module declaration form : ${__module}"
	__parse_item "module" "${__module}" "_MODULE"

	__tango_log "DEBUG" "tango" "set_module : module name : ${_MODULE_NAME}"
	__module="${_MODULE_NAME}"

	# add yml to docker compose file
	case ${_MODULE_OWNER} in
		APP )
			__tango_log "DEBUG" "tango" "set_module : ${__module} is an app module"
			# NOTE : if problem appears with anchors in module
			yq m -i -a=append -- "${GENERATED_DOCKER_COMPOSE_FILE}" <(yq r --explodeAnchors "${TANGO_APP_MODULES_ROOT}/${_MODULE_NAME}.yml")
			#yq m -i -a=overwrite -- "${GENERATED_DOCKER_COMPOSE_FILE}" "${TANGO_APP_MODULES_ROOT}/${_MODULE_NAME}.yml"
		;;
		TANGO )
			__tango_log "DEBUG" "tango" "set_module : ${__module} is a tango module"
			# NOTE : if problem appears with anchors in module
			yq m -i -a=append -- "${GENERATED_DOCKER_COMPOSE_FILE}" <(yq r --explodeAnchors "${TANGO_MODULES_ROOT}/${_MODULE_NAME}.yml")
			#yq m -i -a=overwrite -- "${GENERATED_DOCKER_COMPOSE_FILE}" "${TANGO_MODULES_ROOT}/${_MODULE_NAME}.yml"
		;;
	esac

	# entrypoint
	# NOTE : _MODULE_NETWORK_AREA is setted by __parse_item()
	local __area=
	local __area_services=
	if [ ! "${_MODULE_NETWORK_AREA}" = "" ]; then
		__tango_log "DEBUG" "tango" "set_module : network area declared : $_MODULE_NETWORK_AREA"
		__area="${_MODULE_NETWORK_AREA}"
		__area="NETWORK_SERVICES_AREA_${__area^^}"
		eval "export ${__area}=\"${!__area} ${__module}\""
		__tango_log "DEBUG" "tango" "set_module : ${__module} is now attached to network area : $_MODULE_NETWORK_AREA"
	else
		__tango_log "DEBUG" "tango" "set_module : no network area in ${__module} form declaration"
		if ! __check_traefik_router_exist ${__module}; then
			# attach module to a default network area value only if module name have an associated traefik router
			__tango_log "DEBUG" "tango" "set_module : ${__module} not have any traefik router defined in compose file. May have only subservices."
		else
			# check if module is attached to a network area through variable declaration NETWORK_SERVICES_AREA_* instead of declared via its form <module>[@<network area>]
			for a in ${NETWORK_SERVICES_AREA_LIST}; do
				IFS="|" read -r name proto internal_port secure_port <<<$(echo ${a})
				__area_services="NETWORK_SERVICES_AREA_${name^^}"
				for s in ${!__area_services}; do
					if [ "${s}" = "${__module}" ]; then
						__area="${name}"
						break
					fi
				done
				[ ! "${__area}" = "" ] && break
			done
			if [ "$__area" = "" ]; then
				__area="main"
				__tango_log "DEBUG" "tango" "set_module : ${__module} is now attached to the default tango network area : $__area"
				
				__area="NETWORK_SERVICES_AREA_${__area^^}"
				eval "export ${__area}=\"${!__area} ${_MODULE_NAME}\""
			else
				__tango_log "DEBUG" "tango" "set_module : ${__module} is declared being attached to network area : $__area through variable : ${__area_services}"
			fi
			
		fi
	fi	

	# dependencies
	local __dep_disabled="$($STELLA_API filter_list_with_list "${_MODULE_LINKS}" "${TANGO_SERVICES_DISABLED}" "FILTER_KEEP")"
	[ ! -z "${__dep_disabled}" ] && echo " ** WARN : if ${__module} is enabled, these disabled services will be reactivated as dependencies : ${__dep_disabled}"
	for d in ${_MODULE_LINKS}; do
		__add_service_dependency "${__module}" "${d,,}"
	done

	local _vpn=
	if [ ! "${_MODULE_VPN_ID}" = "" ]; then 
		_vpn="${_MODULE_VPN_ID^^}_SERVICES" && eval "export ${_vpn}=\"${!_vpn} ${__module}\""
	fi

}

# exec all plugins programmed to auto exec at launch of all active service
__exec_auto_plugin_service_active_all() {
	local __plugin
	for s in ${TANGO_SERVICES_ACTIVE}; do
		__exec_auto_plugin_all_by_service ${s}
	done
}

# exec all plugins programmed to auto exec at launch of a service
__exec_auto_plugin_all_by_service() {
	local __service="$1"
	local __plugins="${TANGO_PLUGINS_BY_SERVICE_FULL_AUTO_EXEC[$__service]}"

	if [ ! "${__plugins}" = "" ]; then
		for p in ${__plugins}; do 
			__exec_plugin "${__service}" "${p}"
		done
	fi
}

# exec all plugins attached to a service
__exec_plugin_all_by_service() {
	local __service="$1"
	local __plugins="${TANGO_PLUGINS_BY_SERVICE_FULL[$__service]}"

	if [ ! "${__plugins}" = "" ]; then
		for p in ${__plugins}; do 
			__exec_plugin "${__service}" "${p}"
		done
	fi
}


# exec a plugin into all attached service
__exec_plugin_into_services() {
	local __plugin="$1"
	local __services="${TANGO_SERVICES_BY_PLUGIN_FULL[$__plugin]}"

	if [ ! "${__services}" = "" ]; then
		for s in ${__services}; do 
			__exec_plugin "${s}" "${__plugin}"
		done
	fi
}



# execute a plugin into a service context
__exec_plugin() {
	local __service="$1"
	local __plugin="$2"

	__parse_item "plugin" "${__plugin}" "PLUGIN"

	__tango_log "INFO" "tango" "Plugin execution : ${PLUGIN_NAME}"
	__tango_log "INFO" "tango" "	into service : ${__service}"
	__tango_log "INFO" "tango" "  with args list : ${PLUGIN_ARG_LIST}"

	docker-compose exec --user ${TANGO_USER_ID}:${TANGO_GROUP_ID} ${__service} /bin/sh -c '[ "'${PLUGIN_OWNER}'" = "APP" ] && /pool/'${TANGO_APP_NAME}'/plugins/'${PLUGIN_NAME}' '${PLUGIN_ARG_LIST}' || /pool/tango/plugins/'${PLUGIN_NAME}' '${PLUGIN_ARG_LIST}
}

# filter existing items
# split item list between full list and name list
# build associative array for mapping service and plugin that are attached to 
# type : module | plugin
__filter_items_exists() {
	local __type="${1}"

	local __list_full=
	local __list_names=
	local __app_folder=
	local __tango_folder=
	local __file_ext=
	case ${__type} in
		module )
			__list_full="${TANGO_SERVICES_MODULES}"
			__app_folder="${TANGO_APP_MODULES_ROOT}"
			__tango_folder="${TANGO_MODULES_ROOT}"
			__file_ext='.yml'
		;;

		plugin )
			__list_full="${TANGO_PLUGINS}"
			__app_folder="${TANGO_APP_PLUGINS_ROOT}"
			__tango_folder="${TANGO_PLUGINS_ROOT}"
			__file_ext=
		;;
	
	esac
	__list_names="$(echo "${__list_full}" | sed -e 's/[@%\^#][^ ]* */ /g')"

	# filter existing items
	local __name
	local __full
	local __array_list_names=( $__list_names )
	local __array_list_full=( $__list_full )
	__list_names=
	__list_full=
	for index in ${!__array_list_names[*]}; do
	
		__item_exists=""
		__name="${__array_list_names[$index]}"
		__full="${__array_list_full[$index]}"
		# look for item file in current app
		if [ -f "${__app_folder}/${__name}${__file_ext}" ]; then
			__item_exists="1"
		else
			# look for item file in tango folder
			if [ -f "${__tango_folder}/${__name}${__file_ext}" ]; then
				__item_exists="1"
			fi
		fi

		if [ "${__item_exists}" = "1" ]; then
			__list_names="${__list_names} ${__name}"
			__list_full="${__list_full} ${__full}"
			if [ "${__type}" = "plugin" ]; then
				__parse_item "plugin" "${__array_list_full[$index]}" "PLUGIN"
				for s in ${PLUGIN_LINKS}; do
					TANGO_PLUGINS_BY_SERVICE_FULL["${s}"]="${TANGO_PLUGINS_BY_SERVICE_FULL[$s]} ${__full}"
					TANGO_SERVICES_BY_PLUGIN_FULL["${__name}"]="${TANGO_SERVICES_BY_PLUGIN_FULL[${__name}]} ${s}"
				done
				for s in ${PLUGIN_LINKS_AUTO_EXEC}; do
					TANGO_PLUGINS_BY_SERVICE_FULL_AUTO_EXEC["${s}"]="${TANGO_PLUGINS_BY_SERVICE_FULL_AUTO_EXEC[$s]} ${__full}"
				done
			fi
		else
			echo "* WARN : ${__type} ${__name} not found."
		fi
	done

	# FULL list conserve existing items in full format
	# standard list conserve existing items with only names
	case ${__type} in
		module )
			TANGO_SERVICES_MODULES_FULL="${__list_full}"
			TANGO_SERVICES_MODULES="${__list_names}"
		;;
		plugin )
			TANGO_PLUGINS_FULL="${__list_full}"
			TANGO_PLUGINS="${__list_names}"
		;;
	esac

}

# type : module | plugin
# item format :
#	 	<module>[@<network area>][%<service dependency1>][%<service dependency2>][^<vpn id>]
#		<plugin>[%<auto exec at launch into service1>][%!<manual exec into service2>][#arg1][#arg2]
# __result_prefix : variable prefix to store result
__parse_item() {
	local __type="$1"
	local __item="$2"
	local __result_prefix="$3"

	local __app_folder=
	local __tango_folder=
	local __file_ext=

	# name
	eval ${__result_prefix}_NAME=
	# item is in APP or TANGO folder
	eval ${__result_prefix}_OWNER=
	# arguments list to pass to item
	eval ${__result_prefix}_ARG_LIST=
	# network area to bind item to
	eval ${__result_prefix}_NETWORK_AREA=
	# links list : services dependencies for module OR attach point for plugin (with auto exec at launch or not)
	eval ${__result_prefix}_LINKS=
	# links list : attach point for plugin to services that will be executed at launch
	eval ${__result_prefix}_LINKS_AUTO_EXEC=
	# vpn id to bind item to
	eval ${__result_prefix}_VPN_ID=


	# item name
	local __name=
	case ${__type} in 
		plugin )
			__name="$(echo $__item | sed 's,^\([^#%]*\).*$,\1,')"
			eval ${__result_prefix}_NAME="${__name}"
		;;

		module )
			__name="$(echo $__item | sed 's,^\([^@%\^]*\).*$,\1,')"
			eval ${__result_prefix}_NAME="${__name}"
			;;
	esac
	

	if [ "${__type}" = "plugin" ]; then
		# item arg list
		# symbol : #
		if [ -z "${__item##*#*}" ]; then
			local __arg_list="$(echo $__item | sed 's,^[^#]*#\([^%@\^]*\).*$,\1,')"
			__arg_list="${__arg_list//#/ }"
			eval ${__result_prefix}_ARG_LIST='"'${__arg_list}'"'
		fi
	fi


	if [ "${__type}" = "module" ]; then
		# network area
		# symbol : @
		if [ -z "${__item##*@*}" ]; then
			local __network_area="$(echo $__item | sed 's,^.*@\([^%#\^]*\).*$,\1,')"
			eval ${__result_prefix}_NETWORK_AREA="${__network_area}"
		fi
	fi

	# links list : service dependency or attach point list
	# symbol : %
	if [ -z "${__item##*%*}" ]; then
		local __service_dependency_list="$(echo $__item | sed 's,^[^%]*%\([^@#\^]*\).*$,\1,')"
		__service_dependency_list="${__service_dependency_list//%/ }"
		local __tmp_list=
		local __tmp_list_exec=
		case ${__type} in 
			plugin )
				for d in ${__service_dependency_list}; do
					if [ "${d:0:1}" = "!" ]; then
						# do not auto exec at launch
						__tmp_list="${__tmp_list} ${d//\!/}"
					else
						__tmp_list="${__tmp_list} ${d}"
						__tmp_list_exec="${__tmp_list_exec} ${d}"
					fi
				done
				eval ${__result_prefix}_LINKS='"'${__tmp_list}'"'
				eval ${__result_prefix}_LINKS_AUTO_EXEC='"'${__tmp_list_exec}'"'
			;;
			module )
				eval ${__result_prefix}_LINKS='"'${__service_dependency_list}'"'
			;;
		esac
		
	fi

	if [ "${__type}" = "module" ]; then
		# vpn id
		# symbol : ^
		if [ -z "${__item##*^*}" ]; then
			local __vpn_id="$(echo $__item | sed 's,^.*\^\([^@#%]*\).*$,\1,')"
			eval ${__result_prefix}_VPN_ID="${__vpn_id}"
		fi
	fi

	# determine item owner
	case ${__type} in 
		plugin ) 
			__app_folder="${TANGO_APP_PLUGINS_ROOT}"
			__tango_folder="${TANGO_PLUGINS_ROOT}"
			__file_ext=''
		;;
		module ) 
			__app_folder="${TANGO_APP_MODULES_ROOT}"
			__tango_folder="${TANGO_MODULES_ROOT}"
			__file_ext='.yml'
			;;
	esac

	# we have already test item exists in __filter_items_exists
	# so item is either in APP folder or TANGO folder
	if [ -f "${__app_folder}/${__name}${__file_ext}" ]; then
		eval ${__result_prefix}_OWNER="APP"
	else
		eval ${__result_prefix}_OWNER="TANGO"
	fi

}

# list available modules or plugins or scripts
# type : module | plugin | script
# mode : all (default) | app | tango
__list_items() {
	local __type="${1}"
	local __mode="${2:-all}"

	local __app_folder=
	local __tango_folder=
	local __file_ext=
	case ${__type} in
		module ) __app_folder="${TANGO_APP_MODULES_ROOT}"; __tango_folder="${TANGO_MODULES_ROOT}"; __file_ext='*.yml';;
		plugin ) __app_folder="${TANGO_APP_PLUGINS_ROOT}"; __tango_folder="${TANGO_PLUGINS_ROOT}"; __file_ext='*';;
		script ) __app_folder="${TANGO_APP_SCRIPTS_ROOT}"; __tango_folder="${TANGO_SCRIPTS_ROOT}"; __file_ext='*';;
	esac

	local __result=""
	case ${__mode} in
		all ) __do_app=1; __do_tango=1;;
		app ) __do_app=1; __do_tango=0;;
		tango ) __do_app=0; __do_tango=1;;
	esac

	 
	if [ "${__do_app}" = "1" ]; then
		if ! $STELLA_API "is_dir_empty" "${__app_folder}"; then
			for f in ${__app_folder}/*; do
				case $f in
					$__file_ext )	__result="${__result} $(basename $f | sed s/.yml//)";;
				esac
			done
		fi
	fi
	if [ "${__do_tango}" = "1" ]; then
		if ! $STELLA_API "is_dir_empty" "${__tango_folder}"; then
			for f in ${__tango_folder}/*; do
				case $f in
					$__file_ext )	__result="${__result} $(basename $f | sed s/.yml//)";;
				esac
			done
		fi
	fi

	$STELLA_API list_filter_duplicate "${__result}"
}




# FEATURES MANAGEMENT ------------------------

__set_error_engine() {


	__set_priority_router "error" "${ROUTER_PRIORITY_ERROR_VALUE}"
	case ${NETWORK_REDIRECT_HTTPS} in
		enable )
			# lower error router priority
			__set_redirect_https_service "error"
			;;
	esac

	# activate a widlcard registred domain for match "unknow.domain.com" url
	# wild card "*.domain" certificate generation is attached to error router
	# if we use HTTP challenge we cannot generate a wild card domain, it must be in DNS challenge
	case ${LETS_ENCRYPT} in
		enable|debug )
			case ${LETS_ENCRYPT_CHALLENGE} in
				HTTP )
					__tango_log "DEBUG" "tango" "do not generate a *.domain.com certificate because we use HTTP challenge"
				;;
				DNS )
					__tango_log "DEBUG" "tango" "generate a *.domain.com certificate because we use DNS challenge"
					__add_letsencrypt_service "error"
				;;
			esac
		;;
	esac
	

}

__pick_free_port() {
	local __free_port_list=
	local __exclude=

	# exclude direct access port AND any variable ending with _PORT (for service_PORT variable)
	for p in $(compgen -A variable | grep _PORT$); do
		p="${!p}"
		[[ ${p} =~ ^[0-9]+$ ]] && __exclude="${__exclude} ${p}"
	done
	[ ! "${__exclude}" = "" ] && __exclude="EXCLUDE_LIST_BEGIN ${__exclude} EXCLUDE_LIST_END"

	local __nb_port=0
	for area in ${NETWORK_SERVICES_AREA_LIST}; do
		IFS="|" read -r name proto internal_port secure_port <<<$(echo ${area})
		(( __nb_port ++ ))
		[ ! "$secure_port" = "" ] && (( __nb_port ++ ))
	done

	__free_port_list="$($STELLA_API find_free_port "$__nb_port" "TCP RANGE_BEGIN 10000 RANGE_END 65000 CONSECUTIVE ${__exclude}")"

	if [ ! "${__free_port_list}" = "" ]; then
		__free_port_list=( ${__free_port_list} )
		
		local i=0
		for area in ${NETWORK_SERVICES_AREA_LIST}; do
			IFS="|" read -r name proto internal_port secure_port <<<$(echo ${area})
			
			eval NETWORK_PORT_${name^^}=${__free_port_list[$i]}
			echo "NETWORK_PORT_${name^^}=${__free_port_list[$i]}" > "${GENERATED_ENV_FILE_FREEPORT}"
			(( i ++ ))
			if [ ! "$secure_port" = "" ]; then
				eval NETWORK_PORT_${name^^}_SECURE=${__free_port_list[$i]}
				echo "NETWORK_PORT_${name^^}_SECURE=${__free_port_list[$i]}" >> "${GENERATED_ENV_FILE_FREEPORT}"
				(( i ++ ))
			fi
			# NETWORK_PORT_MAIN=${__free_port_list[0]}
			# NETWORK_PORT_MAIN_SECURE=${__free_port_list[1]}
			# NETWORK_PORT_SECONDARY=${__free_port_list[2]}
			# NETWORK_PORT_SECONDARY_SECURE=${__free_port_list[3]}
			# NETWORK_PORT_ADMIN=${__free_port_list[4]}
			# NETWORK_PORT_ADMIN_SECURE=${__free_port_list[5]}

			# echo "NETWORK_PORT_MAIN=${__free_port_list[0]}" > "${GENERATED_ENV_FILE_FREEPORT}"
			# echo "NETWORK_PORT_MAIN_SECURE=${__free_port_list[1]}" >> "${GENERATED_ENV_FILE_FREEPORT}"
			# echo "NETWORK_PORT_SECONDARY=${__free_port_list[2]}" >> "${GENERATED_ENV_FILE_FREEPORT}"
			# echo "NETWORK_PORT_SECONDARY_SECURE=${__free_port_list[3]}" >> "${GENERATED_ENV_FILE_FREEPORT}"
			# echo "NETWORK_PORT_ADMIN=${__free_port_list[4]}" >> "${GENERATED_ENV_FILE_FREEPORT}"
			# echo "NETWORK_PORT_ADMIN_SECURE=${__free_port_list[5]}" >> "${GENERATED_ENV_FILE_FREEPORT}"
		done
	fi
}

# service_name : attatch vpn to a service_name
# vpn_id : integer id of vpn
# vpn_service_name : vpn docker service
__set_vpn_service() {
 	local __service_name="$1"
	local __vpn_id="$2"
 	local __vpn_service_name="$3"

	yq d -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.networks"
	yq d -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.expose"
	yq d -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.ports"

	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.network_mode" "service:${__vpn_service_name}"

	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "VPN_ID=${__vpn_id}"

	# add volume from vpn service to get conf files into /vpn
	__add_volume_from_service "${__service_name}" "${__vpn_service_name}"

	__add_service_dependency "${__service_name}" "${__vpn_service_name}"

}



__create_vpn() {
	local __vpn_id="$1"
	
	local _tmp=
	local __service_name="vpn_${__vpn_id}"


	_tmp="VPN_${__vpn_id}_PATH"
	local __folder="${!_tmp}"
	_tmp="VPN_${__vpn_id}_VPN_FILES"
	local __vpn_files="${!_tmp}"
	_tmp="VPN_${__vpn_id}_VPN"
	local __vpn="${!_tmp}"
	_tmp="VPN_${__vpn_id}_VPN_AUTH"
	local __vpn_auth="${!_tmp}"
	_tmp="VPN_${__vpn_id}_DNS"
	local __dns="${!_tmp}"
	_tmp="VPN_${__vpn_id}_CERT_AUTH"
	local __cert_auth="${!_tmp}"
	_tmp="VPN_${__vpn_id}_CIPHER"
	local __cipher="${!_tmp}"
	_tmp="VPN_${__vpn_id}_MSS"
	local __mss="${!_tmp}"
	_tmp="VPN_${__vpn_id}_ROUTE"
	local __route="${!_tmp}"
	_tmp="VPN_${__vpn_id}_ROUTE6"
	local __route6="${!_tmp}"
	# !!merge <<: default-vpn
	yq w -i "${GENERATED_DOCKER_COMPOSE_FILE}" --makeAlias "services.${__service_name}.<<" "default-vpn" 
	#yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.<<" default-vpn
	# need tweak '*default-vpn' yaml anchor while this issue exist in yq : https://github.com/mikefarah/yq/issues/377
	#sed -i 's/[^&]default-vpn/ \*default-vpn/' "${GENERATED_DOCKER_COMPOSE_FILE}"
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.container_name" '${TANGO_INSTANCE_NAME}_'${__service_name}
	[ "${__folder}" ] && __add_volume_mapping_service "${__service_name}" "${__folder}:/vpn"
	[ "${__vpn_files}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "VPN_FILES=${__vpn_files}"
	[ "${__vpn}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "VPN=${__vpn}"
	[ "${__vpn_auth}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "VPN_AUTH=${__vpn_auth}"
	[ "${__dns}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "DNS=${__dns}"
	[ "${__cert_auth}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "CERT_AUTH=${__cert_auth}"
	[ "${__cipher}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "CIPHER=${__cipher}"
	[ "${__mss}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "MSS=${__mss}"
	[ "${__route}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "ROUTE=${__route}"
	[ "${__route6}" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service_name}.environment[+]" "ROUTE6=${__route6}"

	export TANGO_TIME_VOLUME_SERVICES="${TANGO_TIME_VOLUME_SERVICES} ${__service_name}"
}

# NOTE : check a docker compose service exist (not a subservice)
__check_docker_compose_service_exist() {
	local __service="$1"
	
	[ ! -z "$(yq r -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.image")" ]
	return $?
}


# if service is a subservice return parent service
__get_subservice_parent() {
	local __service="$1"
	if $STELLA_API list_contains "${TANGO_SUBSERVICES_ROUTER}" "${__service}"; then
		for s in ${TANGO_SERVICES_AVAILABLE}; do
			case ${__service} in
				${s}_* ) echo "${s}"; return ;;
			esac
		done
	fi
}


# return area name associated to an entrypoint
# i.e : entry_main_http or entry_main_http_secure => return main
__get_network_area_name_from_entrypoint() {
	local __entrypoint="$1"
	local result="${__entrypoint,,}"

	# remove entry_
	result="${result##entry_}"
	# remove _secure
	result="${result%%_secure}"
	# remove _proto
	result="${result%_*}"

	echo ${result}
}

# a service (aka a docker compose service) may exist but may not have a default traefik associated router with the same name
# i.e a service may have only associated subservice with router for them but no router for the service name itself
__check_traefik_router_exist() {
	local __service="$1"

	[ ! -z "$(sed -n 's/traefik\.[^.]*\.routers\.'${__service}'\.service=/\0/p' "${GENERATED_DOCKER_COMPOSE_FILE}")" ]
	return $?
}


__add_gpu() {
	local __service="$1"
	local __opt="$2"

	__opt_intel_quicksync=0
	__opt_nvidia=0
	for o in $__opt; do
		[ "${o}" = "INTEL_QUICKSYNC" ] && __opt_intel_quicksync=1
		[ "${o}" = "NVIDIA" ] && __opt_nvidia=1
	done

	if [ "${__opt_intel_quicksync}" = "1" ]; then
		[ -d "/dev/dri" ] && yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.devices[+]" "/dev/dri:/dev/dri"
	fi

	if [ "${__opt_nvidia}" = "1" ]; then
		yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.environment[+]" "NVIDIA_VISIBLE_DEVICES=all"
		yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.environment[+]" "NVIDIA_DRIVER_CAPABILITIES=compute,video,utility"
		yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.runtime" "nvidia"
	fi
}



__add_tz_var_for_time() { 
	local __service="$1"

	if [ -f "/etc/timezone" ]; then
		TZ="$(cat /etc/timezone)"
		yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.environment[+]" "TZ=${TZ}"
	fi
}


# attach generated env compose file to a service
__add_generated_env_file() {
	local __service="$1"

	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.env_file[+]" "${GENERATED_ENV_FILE_FOR_COMPOSE}"
}


__add_service_dependency() {
	local __service="$1"
	local __dependency="$2"

	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.depends_on[+]" "${__dependency}"
}

__add_volume_for_time() {
	local __service="$1"
	
	# create these volumes only if files exists
	[ -f "/etc/timezone" ] && __add_volume_mapping_service "${__service}" "/etc/timezone:/etc/timezone:ro"
	[ -f "/etc/localtime" ] && __add_volume_mapping_service "${__service}" "/etc/localtime:/etc/localtime:ro"
}


__add_letsencrypt_service() {
	local __service="$1"

	# subservice support
	local __parent="$(__get_subservice_parent "${__service}")"
	[ "${__parent}" = "" ] && __parent="${__service}"

	if __check_docker_compose_service_exist "${__parent}"; then
		yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__parent}.labels[+]" "traefik.http.routers.${__service}-secure.tls.certresolver=tango"
	else
		__tango_log "WARN" "tango" "unknow service ${__parent} declared in LETS_ENCRYPT_SERVICES"
	fi
}

# attach an entrypoint to a service or a subservice as well to the secured version of the entrypoint
# it will update a list of entrypoint for the service
# __service : service name
# __network_area : area name
# __secure : "secure|<empty>" declare the entrypoint as secure
# __set_entrypoint_service "web1" "entry_main_http" "secure"
__set_entrypoint_service() {
	local __service="$1"
	local __network_area_name="$2"
	

	local __secure_port
	local __var
	local __previous
	local __proto

	[ "${__network_area_name}" = "" ] && return

	__var="${__service^^}_ENTRYPOINTS"
	if [ ! "${!__var}" = "" ]; then
		__previous=",${!__var}"
	else
		# first entrypoint attached to a service is the default one
		__add_declared_variables "${__service^^}_ENTRYPOINT_DEFAULT"
		__proto="NETWORK_SERVICES_AREA_${__network_area_name^^}_PROTO"
		__proto="${!__proto}"
		eval "export ${__service^^}_ENTRYPOINT_DEFAULT=entry_${__network_area_name}_${__proto}"
		__tango_log "DEBUG" "tango" "assign service : ${s} to entrypoint : entry_${__network_area_name}_${__proto}"
	fi
	eval "export ${__var}=entry_${__network_area_name}_${__proto}${__previous}"
	__add_declared_variables "${__var}"
	

	__secure_port="NETWORK_SERVICES_AREA_${__network_area_name^^}_INTERNAL_SECURE_PORT"
	if [ ! "${!__secure_port}" = "" ]; then
		__var="${__service^^}_ENTRYPOINTS_SECURE"
		if [ ! "${!__var}" = "" ]; then
			__previous=",${!__var}"
		else
			# first entrypoint attached to a service is the default one
			__add_declared_variables "${__service^^}_ENTRYPOINT_DEFAULT_SECURE"
			__proto="NETWORK_SERVICES_AREA_${__network_area_name^^}_PROTO"
			__proto="${!__proto}"
			eval "export ${__service^^}_ENTRYPOINT_DEFAULT_SECURE=entry_${__network_area_name}_${__proto}_secure"
			__tango_log "DEBUG" "tango" "assign service : ${s} to entrypoint : entry_${__network_area_name}_${__proto}_secure"
		fi
		eval "export ${__var}=entry_${__network_area_name}_${__proto}_secure${__previous}"
		__add_declared_variables "${__var}"
	fi

}

# set a priority for a traefik router
__set_priority_router() {	
	local __service="$1"
	local __priority="$2"

	__service="${__service^^}"

	local __var="${__service}_PRIORITY"

	eval "export ${__var}=${__priority}"
	__add_declared_variables "${__var}"
	
}

# change rule priority of a service to be overriden by the http-catchall rule which have a prority of ROUTER_PRIORITY_HTTP_TO_HTTPS_VALUE
__set_redirect_https_service() {
	local __service="$1"
	
	__service="${__service^^}"

	# determine how much priority we have to lower the router
	local __lower_http_router_priority_value="$(( ROUTER_PRIORITY_DEFAULT_VALUE - ROUTER_PRIORITY_HTTP_TO_HTTPS_VALUE + (ROUTER_PRIORITY_HTTP_TO_HTTPS_VALUE / 2) ))"
	# exemple : (( 2000 - 1000 + (1000/2) )) --> 1500 - this is the amount to subtract to an HTTP router priority
	


	local __var="${__service}_PRIORITY"
	__var=${!__var}
	__var="$(($__var - $__lower_http_router_priority_value))"
	__set_priority_router "${__service}" "${__var}" 
	# DEPRECATED : technique was to add a middleware redirect rule for each service
	# add only once ',' separator to compose file only if there is other middlewars declarated 
	# ex : "traefik.http.routers.sabnzbd.middlewares=${SABNZBD_REDIRECT_HTTPS}sabnzbd-stripprefix"
	# sed -i 's/\(.*\)\${'$__service'_REDIRECT_HTTPS}\([^,].\+\)\"$/\1\${'$__service'_REDIRECT_HTTPS},\2\"/g' "${GENERATED_DOCKER_COMPOSE_FILE}"
}

__add_volume_mapping_service() {
	local __service="$1"
	local __mapping="$2"
	
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.volumes[+]" "${__mapping}"
}

__add_volume_from_service() {
	local __service="$1"
	local __from_service="$2"
	
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "services.${__service}.volumes_from[+]" "${__from_service}"
}


__add_volume_local_definition() {
	local __name="$1"
	local __path="$2"

	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "volumes.${__name}.driver" "local"
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "volumes.${__name}.name" "${TANGO_APP_NAME}_${__name}"
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "volumes.${__name}.driver_opts.type" "none"
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "volumes.${__name}.driver_opts.o" "bind"
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "volumes.${__name}.driver_opts.device" "${__path}"
}

__set_network_as_external() {
	local __name="$1"
	local __full_name="$2"

	yq d -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "networks.${__name}.name"
	yq w -i -- "${GENERATED_DOCKER_COMPOSE_FILE}" "networks.${__name}.external.name" "${__full_name}"
}


# DOCKER ---------------------------------

# docker client available
__is_docker_client_available() {
	type docker &>/dev/null
	#which docker 2>/dev/null 1>&2
	return $?
}

__container_is_healthy() {
    local state="$(docker inspect -f '{{ .State.Health.Status }}' $1 2>/dev/null)"
    local return_code=$?
	
    if [ ! ${return_code} -eq 0 ]; then
        exit ${RETURN_ERROR}
    fi
    if [ "${state}" = "healthy" ]; then
        return 0
    else
        return 1
    fi
}


__container_is_running() {
    local state="$(docker inspect -f '{{ .State.Status }}' $1 2>/dev/null)"
    local return_code=$?
	
    if [ ! ${return_code} -eq 0 ]; then
        exit ${RETURN_ERROR}
    fi
    if [ "${state}" = "running" ]; then
        return 0
    else
        return 1
    fi
}




# OPTIONS
# filter user
#		can be empty or "all" to list all container
# filter status options
# 		NON_RUNNING, NON_STOPPED, ONLY_RUNNING, ONLY_STOPPED are exclusive (can not be cumulated with any other filters)
#		RUNNING, STOPPED can be cumulated
#		NON_RUNNING is the same than ONLY_STOPPED
#		NON_STOPPED is the same than ONLY_RUNNING
#		LIST_NAMES name1 name2 name3  : will include filter which have these names
# sample
#		${DOCKER_CMD} ps -a $(__container_filter "ONLY_RUNNING") --format "{{.Names}}#{{.Status}}#{{.Image}}"
__container_filter() {
	local __opt="$1"

	local __opt_running=
	local __opt_non_running=
	local __opt_only_running=
	local __opt_stopped=
	local __opt_non_stopped=
	local __opt_only_stopped=
	local __flag_names=
	local __names_list=
	for o in ${__opt}; do
		[ "$o" = "RUNNING" ] && __opt_running="1" && __opt_non_running="0" && __opt_only_running="0" && __opt_non_stopped="0" && __opt_only_stopped="0" && __flag_names=
		[ "$o" = "NON_RUNNING" ] && __opt_running="0" && __opt_stopped="0" && __opt_non_running="1" && __opt_only_running="0" && __opt_non_stopped="0" && __opt_only_stopped="0" && __flag_names=
		[ "$o" = "ONLY_RUNNING" ] && __opt_running="0" && __opt_stopped="0" && __opt_non_running="0" && __opt_only_running="1" && __opt_non_stopped="0" && __opt_only_stopped="0" && __flag_names=
		[ "$o" = "STOPPED" ] && __opt_stopped="1" && __opt_non_running="0" && __opt_only_running="0" && __opt_non_stopped="0" && __opt_only_stopped="0" && __flag_names=
		[ "$o" = "NON_STOPPED" ] && __opt_running="0" && __opt_stopped="0" && __opt_non_running="0" && __opt_only_running="0" && __opt_non_stopped="1" && __opt_only_stopped="0" && __flag_names=
		[ "$o" = "ONLY_STOPPED" ] && __opt_running="0" && __opt_stopped="0" && __opt_non_running="0" && __opt_only_running="0" && __opt_non_stopped="0" && __opt_only_stopped="1" && __flag_names=
		[ "$__flag_names" = "1" ] && __names_list="$__names_list $o"
		[ "$o" = "LIST_NAMES" ] && __flag_names=1
	done

	local __filter_default="--filter=label=${TANGO_INSTANCE_NAME}.managed=true"

	local __filter_names=
	if [ ! "${__names_list}"  = "" ]; then
		__names_list="$($STELLA_API trim "${__names_list}")"
		__filter_names="--filter=name=^/$(echo -n ${__names_list} | sed -e 's/ /$|^\//g')$"
	fi

	local __filter_status=
	[ "$__opt_running" = "1" ] && __filter_status="${__filter_status} --filter=status=running"
	[ "$__opt_stopped" = "1" ] && __filter_status="${__filter_status} --filter=status=exited --filter=status=created"
	[ "$__opt_non_running" = "1" ] && __filter_status="--filter=status=exited --filter=status=created"
	[ "$__opt_only_running" = "1" ] && __filter_status="--filter=status=running"
	[ "$__opt_non_stopped" = "1" ] && __filter_status="--filter=status=running"
	[ "$__opt_only_stopped" = "1" ] && __filter_status="--filter=status=exited --filter=status=created"



	echo "${__filter_default} ${__filter_names} ${__filter_status}"
}


docker-compose() {
	# NOTE we need to specify project directory because when launching from an other directory, docker compose seems to NOT auto load .env file
	case ${TANGO_INSTANCE_MODE} in
		shared ) 
			__tango_log "DEBUG" "tango" "COMPOSE_IGNORE_ORPHANS=1 docker-compose ${DOCKER_COMPOSE_LOG} -f "${GENERATED_DOCKER_COMPOSE_FILE}" --env-file "${GENERATED_ENV_FILE_FOR_COMPOSE}" --project-name "${TANGO_INSTANCE_NAME}" --project-directory "${TANGO_APP_ROOT}" "$@""
			COMPOSE_IGNORE_ORPHANS=1 command docker-compose ${DOCKER_COMPOSE_LOG} -f "${GENERATED_DOCKER_COMPOSE_FILE}" --env-file "${GENERATED_ENV_FILE_FOR_COMPOSE}" --project-name "${TANGO_INSTANCE_NAME}" --project-directory "${TANGO_APP_ROOT}" "$@"
			;;
		* ) 
			__tango_log "DEBUG" "tango" "COMPOSE_IGNORE_ORPHANS=1 docker-compose ${DOCKER_COMPOSE_LOG} -f "${GENERATED_DOCKER_COMPOSE_FILE}" --env-file "${GENERATED_ENV_FILE_FOR_COMPOSE}" --project-name "${TANGO_APP_NAME}" --project-directory "${TANGO_APP_ROOT}" "$@""
			COMPOSE_IGNORE_ORPHANS=1 command docker-compose ${DOCKER_COMPOSE_LOG} -f "${GENERATED_DOCKER_COMPOSE_FILE}" --env-file "${GENERATED_ENV_FILE_FOR_COMPOSE}" --project-name "${TANGO_APP_NAME}" --project-directory "${TANGO_APP_ROOT}" "$@"
			;;
	esac
	
}

# VARIOUS -----------------

# generate a string to be used as header Authentification: Basic
__base64_basic_authentification() {
	local __user="$1"
	local __password="$2"

	python -c 'import base64;print(base64.b64encode(b"'$__user':'$__password'").decode("ascii"))'
}

# launch a curl command from a docker image in priority if docker is available or from curl from host if not
__tango_curl() {
	if __is_docker_client_available; then
		local __id="mambo_$($STELLA_API md5 "$@")"
		docker stop $__id 1>&2 2>/dev/null
		docker rm $__id 1>&2 2>/dev/null
		docker run --name $__id --user "${TANGO_USER_ID}:${TANGO_GROUP_ID}" --network "${TANGO_APP_NETWORK_NAME}" --rm curlimages/curl:7.70.0 "$@"
		docker rm $__id 1>&2 2>/dev/null
	else
		type curl &>/dev/null && curl "$@"
	fi
}

# launch a git command from a docker image in priority if docker is available or from git from host if not
__tango_git() {
	if __is_docker_client_available; then
		# https://hub.docker.com/r/alpine/git
		docker run --user "${TANGO_USER_ID}:${TANGO_GROUP_ID}" --network "${TANGO_APP_NETWORK_NAME}" --rm -it -v $(pwd):/git alpine/git:latest "$@"
	else
		type git &>/dev/null && git "$@"
	fi
}

# set an attribute value of a node selected by an xpath expression
# 	__xml_replace_attribute_value "Preferences.xml" "/Preferences" "Preferences" "TranscoderTempDirectory" "/transode"
# 	xidel Preferences.xml --silent --xml --xquery3 'let $selected := /Preferences return transform(/,function($e) { if ($selected[$e is .]) then <Preferences>{$e/attribute() except $e/@TranscoderTempDirectory, attribute TranscoderTempDirectory { "/transcode" },$e/node()}</Preferences> else $e })'
# http://x-query.com/pipermail/talk/2013-December/004266.html
__xml_set_attribute_value() {
	local __file="$1"
	local __xpath_selector="$2"
	local __node_name="$3"
	local __attribute_name="$4"
	local __attribute_value="$5"


	xidel "${__file}" --silent --xml --xquery3 'let $selected := '${__xpath_selector}' return transform(/,function($e) { if ($selected[$e is .]) then <'${__node_name}'>{$e/attribute() except $e/@'${__attribute_name}', attribute '${__attribute_name}' { "'${__attribute_value}'" },$e/node()}</'${__node_name}'> else $e })' > "${__file}.new"
	rm -f "${__file}"
	mv "${__file}.new" "${__file}"
}

# get an attribute value 
#		__xml_get_attribute_value "Preferences.xml" "/Preferences/@PlexOnlineToken"
__xml_get_attribute_value() {
	local __file="$1"
	local __xpath_selector="$2"

	xidel "${__file}" --silent --extract "${__xpath_selector}"
}


# simple extract value in an ini file
# support	key=value and key = value
__ini_get_key_value() {
	local __file="$1"
	local __key="$2"

	if [ ! -z $__key ]; then
		if [ -f "${__file}" ]; then
	        cat "${__file}" | sed -e 's,'$__key'[[:space:]]*=[[:space:]]*,'$__key'=,g' | awk 'match($0,/^'$__key'=.*$/) {print substr($0, RSTART+'$(( ${#__key} + 1 ))',RLENGTH);}'
    	fi            
	fi
}

# create all path according to _SUBPATH_CREATE variables content
# see __create_path
__create_path_all() {
	local __create_path_instructions=
	local __root=

	# force to create first these root folders before all other that might be subfolders
	if [ ! "${TANGO_APP_WORK_ROOT_SUBPATH_CREATE}" = "" ]; then
		__tango_log "DEBUG" "tango" "create_path_all : parse TANGO_APP_WORK_ROOT_SUBPATH_CREATE instructions"
		__create_path "${TANGO_APP_WORK_ROOT}" "${TANGO_APP_WORK_ROOT_SUBPATH_CREATE}"
	fi
	if [ ! "${TANGO_DATA_PATH_SUBPATH_CREATE}" = "" ]; then
		__tango_log "DEBUG" "tango" "create_path_all : parse TANGO_DATA_PATH_SUBPATH_CREATE instructions"
		__create_path "${TANGO_DATA_PATH}" "${TANGO_DATA_PATH_SUBPATH_CREATE}"
	fi

	# create others folders
	for p in $(compgen -A variable | grep _SUBPATH_CREATE$); do
		[ "$p" = "TANGO_APP_WORK_ROOT_SUBPATH_CREATE" ] && continue
		[ "$p" = "TANGO_DATA_PATH_SUBPATH_CREATE" ] && continue
		__tango_log "DEBUG" "tango" "create_path_all : instructions of ${p}"
		__create_path_instructions="${!p}"
		if [ ! "${__create_path_instructions}" = "" ]; then
			__root="${p%_SUBPATH_CREATE}"
			[ ! "${!__root}" = "" ] && __create_path "${!__root}" "${__create_path_instructions}"
		fi
	done
}

# create various sub folder and files if not exist
# using TANGO_USER_ID
# root must exist
# format example : __create_path "/path" "FOLDER foo bar FILE foo/file.txt FOLDER letsencrypt traefikconfig FILE letsencrypt/acme.json traefikconfig/generated.${TANGO_APP_NAME}.tls.yml"
__create_path() {
	local __root="$1"
	local __list="$2"

	 
	local __folder=
	local __file=

	# we do not want to alter filesystem (files & folder)
	[ "$TANGO_ALTER_GENERATED_FILES" = "OFF" ] && return

	if [ ! -d "${__root}" ]; then
		__tango_log "ERROR" "tango" "create_path : root path ${__root} do not exist"
		return
	fi

	__tango_log "DEBUG" "tango" "create_path : ROOT=${__root} INSTRUCTIONS=${__list}"
	local cpt=0
	for p in ${__list}; do
		[ "${p}" = "FOLDER" ] && __folder=1 && __file= && continue
		[ "${p}" = "FILE" ] && __folder= && __file=1 && continue
		__path="${__root}/${p}"
		# NOTE : on some case chown throw an error, it might be ignored
		if [ "${__folder}" = "1" ]; then
			if [ ! -d "${__path}" ]; then
				__msg=$(docker run -it --rm --user ${TANGO_USER_ID}:${TANGO_GROUP_ID} -v "${__root}":"/foo" ${TANGO_SHELL_IMAGE} bash -c 'mkdir -p /foo/'${p}' && chown '${TANGO_USER_ID}':'${TANGO_GROUP_ID}' /foo/'${p})
				[ ! "${__msg}" = "" ] && __tango_log "DEBUG" "tango" "create_path : msg : ${__msg}"
				# wait more time if not created yet
				__tango_log "DEBUG" "tango" "create_path : Wait for folder $__path exists"
				cpt=0
				while [ ! -d "$__path" ]
				do
					printf "."
					__tango_log "DEBUG" "tango" "create_path : Wait for folder $__path exists"
					sleep 1
					(( cpt++ ))
					if [ $cpt -gt 10 ]; then
						__tango_log "ERROR" "tango" "create_path : Error while creating folder $__path"
						exit 1
					fi
				done
				echo
				__tango_log "DEBUG" "tango" "create_path : done"
			fi
		fi
		if [ "${__file}" = "1" ]; then
			if [ ! -f "${__path}" ]; then
				__msg=$(docker run -it --rm --user ${TANGO_USER_ID}:${TANGO_GROUP_ID} -v "${__root}":"/foo" ${TANGO_SHELL_IMAGE} bash -c 'touch /foo/'${p}' && chown '${TANGO_USER_ID}':'${TANGO_GROUP_ID}' /foo/'${p})
				[ ! "${__msg}" = "" ] && __tango_log "DEBUG" "tango" "create_path : msg : ${__msg}"
				# wait more time if not created yet
				__tango_log "DEBUG" "tango" "create_path : Wait for file $__path exists"
				cpt=0
				while [ ! -f "$__path" ]
				do
					printf "."
					__tango_log "DEBUG" "tango" "create_path : Wait for file $__path exists"
					sleep 1
					(( cpt++ ))
					if [ $cpt -gt 10 ]; then
						__tango_log "ERROR" "tango" "create_path : Error while creating file $__path"
						exit 1
					fi
				done
				echo
				__tango_log "DEBUG" "tango" "create_path : done"
			fi
		fi
	done


}





# test if mandatory paths exists
__check_mandatory_path() {
	local __mode="$1"

	for p in ${TANGO_PATH_LIST}; do
		[ ! -d "${!p}" ] && echo "* ERROR : Mandatory root path ${p} [${!p}] do not exist" && [ ! "${__mode}" = "WARN" ] && exit 1
	done 

	if [ ! "${TANGO_ARTEFACT_FOLDERS}" = "" ]; then
		for f in ${TANGO_ARTEFACT_FOLDERS}; do
			[ ! -d "${f}" ] && echo "* ERROR : Mandatory declared artefact folder [${f}] do not exist" && [ ! "${__mode}" = "WARN" ] && exit 1
		done
	fi
}



__check_lets_encrypt_settings() {
	local __mode="$1"
	local __exit=
 	case ${LETS_ENCRYPT} in
    	enable|debug ) 
			[ "${LETS_ENCRYPT_MAIL}" = "" ] && echo "* ERROR : you have to specify a mail as identity into LETS_ENCRYPT_MAIL variable when using let's encrypt." && __exit=1
			[ "${TANGO_DOMAIN}" = '.*' ] && echo "* ERROR : you cannot use a generic domain (.*) setted by TANGO_DOMAIN when using let's encrypt. Set TANGO_DOMAIN variables or --domain comand line option with other value." && __exit=1
			[ "${TANGO_DOMAIN}" = "" ] && echo "* ERROR : you have to set a domain with TANGO_DOMAIN variable or --domain comand line option when using let's encrypt." && __exit=1
			[ ! "${NETWORK_PORT_MAIN}" = "80" ] && echo "* ERROR : main area network HTTP port is not 80 but ${NETWORK_PORT_MAIN}. You need to use DNS challenge for let's encrypt. Set LETS_ENCRYPT_CHALLENGE* variables." && __exit=1
			[ ! "${NETWORK_PORT_MAIN_SECURE}" = "443" ] && echo "* ERROR : main area network HTTPS port is not 443 but ${NETWORK_PORT_MAIN_SECURE}. You need to use DNS challenge for let's encrypt. Set LETS_ENCRYPT_CHALLENGE* variables" && __exit=1
		;;
	esac

	[ ! "${__mode}" = "warn" ] && [ "${__exit}" = "1" ] && exit 1
}


__tango_log() {
	local __level="$1"
	local __domain="$2"
	shift 2
	local __msg="$@"

	if [ "$TANGO_LOG_STATE" = "ON" ]; then
		_print="0"

		local _color=
		local _reset_color_for_msg="1"
		case ${__level} in
				INFO )
					_color="clr_bold clr_green"
				;;
				WARN )
					_color="clr_bold"
				;;
				ERROR )
					_color="clr_bold clr_red"
					_reset_color_for_msg="0"
				;;
				DEBUG )
					_color=
				;;
				ASK )
					_color="clr_bold clr_blue"
				;;
		esac

		case $TANGO_LOG_LEVEL in
			INFO )
				case ${__level} in
					INFO|WARN|ERROR|ASK ) _print="1"
					;;
				esac
				;;
			WARN )
				case ${__level} in
					INFO|WARN|ERROR|ASK ) _print="1"
					;;
				esac
			;;
			ERROR )
				case ${__level} in
					INFO|WARN|ERROR|ASK ) _print="1"
					;;
				esac
			;;
			DEBUG )
				case ${__level} in
					INFO|WARN|ERROR|DEBUG|ASK ) _print="1"
					;;
				esac
			;;
		esac

		if [ "${_print}" = "1" ]; then
			case ${__level} in
				# add spaces for tab alignment
				INFO|WARN ) __level="${__level} ";;
				ASK ) __level="${__level}  ";;
			esac
			if [ "${_color}" = "" ]; then
				echo "${__level}@${__domain}> ${__msg}"
			else
				if [ "${_reset_color_for_msg}" = "1" ]; then
					${_color} -n "${__level}@${__domain}> "; clr_reset "${__msg}"
				else
					${_color} "${__level}@${__domain}> ${__msg}"
				fi
			fi
		fi
	fi
}

# trash any output
__tango_log_run_without_output() {
	local __domain="$1"
	shift 1
	if [ "${TANGO_LOG_STATE}" = "ON" ]; then
		if [ "${TANGO_LOG_LEVEL}" = "DEBUG" ]; then
			#echo "DEBUG>" $@
			__tango_log "DEBUG" "$__domain" "$@"
		fi
	fi

	if [ "${TANGO_LOG_LEVEL}" = "DEBUG" ]; then
		"$@"
	else
		"$@" 1>/dev/null
	fi
}

# usefull when attachin tty (1>/dev/null make terminal disappear)
__tango_log_run_with_output() {
	local __domain="$1"
	shift 1
	if [ "${TANGO_LOG_STATE}" = "ON" ]; then
		if [ "${TANGO_LOG_LEVEL}" = "DEBUG" ]; then
			#echo "DEBUG>" $@
			__tango_log "DEBUG" "$__domain" "$@"
		fi
	fi
	"$@"
}