#!/bin/bash

# This script is used to sync the signomix-view source code with the signomix-webapp source code

cp ../signomix-webapp/src/lib/*.js ../signomix-view/src/lib
cp ../signomix-webapp/src/lib/components/widgets/* ../signomix-view/src/lib/components/widgets
cp ../signomix-webapp/src/lib/components/AlertForm.svelte ../signomix-view/src/lib/components
cp ../signomix-webapp/src/lib/components/DashboardFilterForm.svelte ../signomix-view/src/lib/components
cp ../signomix-webapp/src/lib/components/DashboardLinkForm.svelte ../signomix-view/src/lib/components
cp ../signomix-webapp/src/lib/components/Dialog.svelte ../signomix-view/src/lib/components