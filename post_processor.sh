cd infrastructure
ARO_SCRIPT_LOCATION="../aro_creation_script_manual.txt"
SSH_PRIVATE_KEY="../id_temp_bastion"
chmod 0700 ${SSH_PRIVATE_KEY}
terraform output --raw aro_call > ${ARO_SCRIPT_LOCATION}
echo "" >> ${ARO_SCRIPT_LOCATION}
terraform output --raw aro_cred_list >> ${ARO_SCRIPT_LOCATION}
echo "" >> ${ARO_SCRIPT_LOCATION}
terraform output --raw aro_cred_url >> ${ARO_SCRIPT_LOCATION}
echo "" >> ${ARO_SCRIPT_LOCATION}
terraform output --raw aro_bastion >> ${ARO_SCRIPT_LOCATION}
echo "" >> ${ARO_SCRIPT_LOCATION}
terraform output --raw aro_internal_addresses_call >> ${ARO_SCRIPT_LOCATION}
echo "" >> ${ARO_SCRIPT_LOCATION}
cat terraform.tfstate  | jq ".outputs.tls_private_key_bastion.value" | sed "s|\\\\n|\n|g" > ${SSH_PRIVATE_KEY} | sed 's|"||g'
chmod 0400 ${SSH_PRIVATE_KEY}
cd -