#!/bin/sh

# Script per comporre il file config.template.yml finale da più template separati
# Questo script concatena i vari file YAML mantenendo la struttura corretta

TEMPLATE_DIR="/flemmarr-templates/templates"
OUTPUT_FILE="/flemmarr-config/config.template.yml"

echo "Composing flemmarr config from separate templates..."

# Crea il file di output vuoto
> "$OUTPUT_FILE"

# Lista dei servizi nell'ordine corretto
services="sonarr radarr prowlarr bazarr"

# Componi il file finale
for service in $services; do
    template_file="$TEMPLATE_DIR/${service}.yml"
    
    if [ -f "$template_file" ]; then
        echo "Adding $service configuration..."
        cat "$template_file" >> "$OUTPUT_FILE"
        
        # Aggiungi una riga vuota tra le sezioni (eccetto per l'ultimo)
        if [ "$service" != "bazarr" ]; then
            echo "" >> "$OUTPUT_FILE"
        fi
    else
        echo "Warning: Template file $template_file not found"
    fi
done

echo "Configuration file composed at $OUTPUT_FILE"
echo "Total lines: $(wc -l < "$OUTPUT_FILE")"
