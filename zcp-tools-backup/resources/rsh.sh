#!/bin/sh
pod=$1;shift;kubectl exec -it $pod -- "$@"
