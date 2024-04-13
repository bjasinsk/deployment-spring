#!/bin/bash

echo "Inicjalizacja maszyn wirtualnych..."
./initMachinesConfig1.sh

if [ $? -eq 0 ]; then
    echo "Inicjalizacja maszyn wirtualnych zakończona sukcesem."
    echo "Uruchamianie skryptu run-all.sh..."

    if [ -f "config.sh" ]; then
        source config.sh
    fi

    ./run-all.sh
else
    echo "Inicjalizacja maszyn wirtualnych nie powiodła się."
fi
