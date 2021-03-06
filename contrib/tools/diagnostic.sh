#!/bin/bash
# Copyright 2016 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

DIAG_DIR=/var/lma_diagnostics

. "$(dirname "$(readlink -f "$0")")"/common.sh

node_list=$(get_ready_nodes)

rm -rf "$DIAG_DIR"
mkdir $DIAG_DIR

echo "Running lma_diagnostic tool on all nodes which are ready and online (this can take several minutes)"
mco rpc --timeout 300 --verbose --display all --agent execute_shell_command --action execute --argument cmd="/usr/local/bin/lma_diagnostics" > "$DIAG_DIR/outputs.log" 2>&1

for n in $node_list; do
    echo "Downloading diagnostic for node $n"
    rsync -arz "$n:$DIAG_DIR" "$DIAG_DIR/$n/" || echo "Fail to retrieve diagnostic from $n"
done

fuel plugins > "$DIAG_DIR/fuel_plugins"

CURRENT_DATE=$(date +%Y-%m-%d_%H-%M-%s)
tar czvf "${DIAG_DIR}.${CURRENT_DATE}.tgz" -C "$DIAG_DIR" . >/dev/null
echo "The diagnostic archive is here: ${DIAG_DIR}.${CURRENT_DATE}.tgz"

exit 0
