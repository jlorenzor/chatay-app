#!/bin/bash

# Número de nodos a desplegar
NUM_NODES=4

# Directorio base para los datos de los nodos
BASE_DIR="./chain_data"

# Puerto base para P2P
BASE_P2P_PORT=30333

# Puerto base para RPC
BASE_RPC_PORT=9933

# Puerto base para WebSocket
BASE_WS_PORT=9944

# Compilar el nodo
echo "Compilando el nodo..."
cargo build --release

# Generar la especificación de la cadena personalizada
./target/release/node-template build-spec --disable-default-bootnode --chain dev > customSpec.json

# Crear la especificación raw
./target/release/node-template build-spec --chain=customSpec.json --raw --disable-default-bootnode > customSpecRaw.json

# Función para generar una clave de nodo
generate_node_key() {
    ./target/release/node-template key generate-node-key
}

# Iniciar los nodos
for i in $(seq 0 $((NUM_NODES-1)))
do
    NODE_DIR="${BASE_DIR}/node${i}"
    mkdir -p $NODE_DIR

    # Generar clave de nodo
    NODE_KEY=$(generate_node_key)
    echo "Clave del nodo ${i}: ${NODE_KEY}"

    P2P_PORT=$((BASE_P2P_PORT + i))
    RPC_PORT=$((BASE_RPC_PORT + i))
    WS_PORT=$((BASE_WS_PORT + i))

    # Iniciar el nodo
    ./target/release/node-template \
        --base-path "${NODE_DIR}" \
        --chain ./customSpecRaw.json \
        --port $P2P_PORT \
        --ws-port $WS_PORT \
        --rpc-port $RPC_PORT \
        --node-key $NODE_KEY \
        --validator \
        --rpc-methods Unsafe \
        --name "node${i}" \
        --bootnodes /ip4/127.0.0.1/tcp/${BASE_P2P_PORT}/p2p/${NODE_KEY} \
        >> "${NODE_DIR}/node.log" 2>&1 &

    echo "Nodo ${i} iniciado con PID $!"
done

echo "Todos los nodos han sido iniciados."
