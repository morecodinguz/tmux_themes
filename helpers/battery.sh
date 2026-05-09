#!/bin/sh
# Print battery percentage like "94%" (macOS).
pmset -g batt 2>/dev/null | grep -Eo '[0-9]+%' | head -n1
