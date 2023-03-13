#!/bin/bash

# Part 2. Automate tasks with JSON files
# Using Vim or Nano editor create a shell script (update-pipeline-definition.sh) that will modify with the JQ lib (here you can find some examples) this JSON file and create a new one (e.g. pipeline-{date-of-creation}.json) with the following changes:
# The metadata property is removed.
# The value of the pipeline’s version property is incremented by 1.
# The Branch property in the Source action’s configuration is set to a value from the script’s parameter/flag --branch. The default value is main. (Assume that it is a branch name of a feature you’re going to point your pipeline).
# The Owner property in the Source action’s configuration is set to a value from the script’s parameter/flag --owner. (Assume that it is a GitHub owner/account name of a repository you’re going to use within the pipeline).
# [Optionally], the Repo property in the Source action’s configuration is set to a value from the script’s parameter/flag --repo. (Assume that it is a GitHub repository you’re going to use within the pipeline).
# The PollForSourceChanges property in the Source action’s configuration is set to a value from the script’s parameter/flag --poll-for-source-changes. (Assume that it is a property that activates and deactivates the automatic pipeline execution when source code is changed). The default value is false.
# The EnvironmentVariables properties in each action are filled with a stringified JSON object containing the BUILD_CONFIGURATION value from the --configuration parameter flag.
# The path to the _pipeline.json _ or another JSON definition file should be passed as the first argument to the script. The following execution should produce a pipeline definition like this one.
#  $ ./update-pipeline-definition.sh ./pipeline.json --configuration production --owner boale --branch feat/cicd-lab --poll-for-source-changes true
# The script should validate if JQ is installed on the host OS. If not, display commands on how to install it on different platforms and stop script execution.
# The script should validate if the necessary properties are present in the given JSON definition. If not, it should throw an error and stop execution.
# The script should validate if the path to the pipeline definition JSON file is provided. If not, it should throw an error and stop execution.
# It should perform only 1.1 and 1.2 actions if no additional parameters are provided. E.g.: $ ./update-pipeline-definition.sh ./pipeline.json.
# [Optionally] implement a --help parameter which will display instructions on how to use the script.
# [Optionally] update the script to ask a user to prompt each argument in a wizard-style (feel free to style it as you wish):
#   $ ./update-pipeline-definition.sh
#     > Please, enter the pipeline’s definitions file path (default: pipeline.json): 
#     > Which BUILD_CONFIGURATION name are you going to use (default: “”):
#     > Enter a GitHub owner/account: boale
#     > Enter a GitHub repository name: shop-angular-cloudfront
#     > Enter a GitHub branch name (default: develop): feat/cicd-lab
#     > Do you want the pipeline to poll for changes (yes/no) (default: no)?: yes
#     > Do you want to save changes (yes/no) (default: yes)?: yes

# The script should validate if JQ is installed on the host OS. 
# If not, display commands on how to install it on different platforms and stop script execution.
function check_jq_installed() {
    type jq > /dev/null
    if [ ! $? ]
        then 
        echo "jq is not installed"; 
        echo "Ubuntu Installation: sudo apt-get install jq"
        echo "Mac Installation:    brew install jq"
        exit 0
    fi
}

check_jq_installed

SOURCE_PIPELINE=$1
DEST_PIPELINE="pipeline-$(date +'%F').json"
TMP=tmp.json
POLL_FOR_SOURCE_CHANGES=false
BRANCH=main

# The script should validate if the path to the pipeline definition JSON file is provided. 
# If not, it should throw an error and stop execution.
if [ -z $1 ]; then
    echo "Error. The path to the pipeline definition JSON file is provided."
    exit 1;
fi

if [ -z $2 ]; then
    BASIC_TRANSFORMATION=true
fi

# Reading space-separated arguments and options
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      BRANCH="$2"
      shift # past argument
      shift # past value
      ;;
    --owner)
      OWNER="$2"
      shift # past argument
      shift # past value
      ;;
    --repo)
      REPO="$2"
      shift # past argument
      shift # past value
      ;;
    --configuration)
      CONFIGURATION="$2"
      shift # past argument
      shift # past value
      ;;
    --poll-for-source-changes)
      POLL_FOR_SOURCE_CHANGES="$2"
      shift # past argument
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters


# The script should validate if the necessary properties are present in the given JSON definition. 
# If not, it should throw an error and stop execution.
if [[ (-z $OWNER || -z $REPO || -z $CONFIGURATION) && ! $BASIC_TRANSFORMATION ]]; then
    echo "Error. Necessary properties are not provided."
    exit 1
fi

# It should perform only 1.1 and 1.2 actions if no additional parameters are provided. 
# E.g.: $ ./update-pipeline-definition.sh ./pipeline.json.
jq 'del(.metadata) | .pipeline.version = .pipeline.version + 1' $SOURCE_PIPELINE > $DEST_PIPELINE


# Extra transformation with additional parameters
if [[ $OWNER && $REPO && $CONFIGURATION ]]; then

    BUILD_CONFIGURATION_JSON='[{"name":"BUILD_CONFIGURATION","value":"'"$CONFIGURATION"'","type":"PLAINTEXT"}]';

    jq --arg branch $BRANCH --arg owner $OWNER --arg repo $REPO --arg pollForSourceChanges $POLL_FOR_SOURCE_CHANGES --arg conf $BUILD_CONFIGURATION_JSON '
    .pipeline.stages[0].actions[0].configuration.Branch = $branch |
    .pipeline.stages[0].actions[0].configuration.Owner = $owner // .pipeline.stages[0].actions[0].configuration.Owner |
    .pipeline.stages[0].actions[0].configuration.Repo = $repo // .pipeline.stages[0].actions[0].configuration.Repo |
    .pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $pollForSourceChanges |
    .pipeline.stages[1,3].actions[0].configuration.EnvironmentVariables = $conf
    ' $DEST_PIPELINE > "tmp" && mv "tmp" $DEST_PIPELINE
fi

exit 0