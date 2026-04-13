#!/bin/bash

OUTPUT = $(siege -c 5 -t 5 http://localhost:8983/solr/selectcore/select?q=TCP) 

echo ${OUTPUT}