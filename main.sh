#!/bin/bash

# URL de la API
url="https://www.cordiez.com.ar/api/catalog_system/pub/products/search"

# Parámetros de la consulta predeterminados
from=0
to=4
order="OrderByPriceASC"

# Función para mostrar un mensaje de carga animado
loading_animation() {
    local delay=0.1
    local i=1
    while true; do
        case $i in
        1)
            printf "Cargando...| \r"
            ;;
        2)
            printf "Cargando.../ \r"
            ;;
        3)
            printf "Cargando...- \r"
            ;;
        4)
            printf "Cargando...\ \r"
            ;;
        *)
            i=0
            ;;
        esac
        i=$((i + 1))
        sleep "$delay"
    done
}

# Procesar las opciones de línea de comandos
while getopts "f:" opt; do
    case "$opt" in
    f)
        # Reemplazar espacios por %20 en el valor de "ft"
        ft=$(echo "$OPTARG" | sed 's/ /%20/g')
        ;;
    \?)
        echo "Uso: $0 -f FT_VALUE"
        exit 1
        ;;
    esac
done

# Verificar si se proporcionó la opción "-f" y el valor de "ft"
if [ -z "$ft" ]; then
    echo "Debes proporcionar un valor para -f (ft)."
    exit 1
fi

# Iniciar el mensaje de carga
loading_animation &

# Obtener el ID del proceso en segundo plano
loading_pid=$!

# Realizar la solicitud GET a la API y guardar la respuesta en un archivo temporal
curl "$url?_from=$from&_to=$to&O=$order&ft=$ft" -o response.json >/dev/null 2>&1

# Detener el mensaje de carga
kill "$loading_pid" >/dev/null 2>&1

# Comprobar si la solicitud fue exitosa (código de estado 200)
if [ $? -eq 0 ]; then
    # Mostrar la línea de resultados en mayúsculas y con guiones
    echo "-----------------------------------------"
    echo "RESULTADOS PARA: ${ft^^}"
    echo "-----------------------------------------"

    # Utilizar jq para extraer los datos requeridos y mostrarlos
    jq -r '.[] | "Nombre del producto: \(.productName)\nMarca: \(.brand)\nPrecio: \(.items[0].sellers[0].commertialOffer.Price)\n------------------------------"' response.json
else
    echo "La solicitud a la API falló para ft: $ft"
fi

# Eliminar el archivo temporal de respuesta
rm response.json
