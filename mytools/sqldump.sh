#!/bin/bash
pg_dump -h localhost -U bankencore -d bankencore_development -s --no-owner --no-privileges -f schema.sql
