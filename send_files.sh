#!/bin/bash

read -p "Digite o usuário SSH do Raspberry Pi: " USER
read -p "Digite o IP ou hostname do Raspberry Pi: " HOST
read -p "Digite o diretório destino no Raspberry (ex: /home/pi/scripts): " DEST_DIR

echo "Informe os nomes dos Raspberries que deseja enviar (ex: RASP_001). Digite ENTER vazio para sair."

while true; do
  read -p "Nome do Raspberry: " RASP_NAME
  if [[ -z "$RASP_NAME" ]]; then
    echo "Saindo..."
    break
  fi
  
  # Extrai número do nome, assumindo padrão RASP_XXX
  NUMERO=$(echo "$RASP_NAME" | grep -oE '[0-9]{3}')
  
  if [[ -z "$NUMERO" ]]; then
    echo "⚠ Nome inválido, deve conter um número com 3 dígitos, ex: RASP_001"
    continue
  fi
  
  FILE="sensor_rasp_${NUMERO}.py"
  
  if [[ ! -f "$FILE" ]]; then
    echo "⚠ Arquivo $FILE não encontrado, tente outro nome."
    continue
  fi
  
  echo "Enviando $FILE para $USER@$HOST:$DEST_DIR ..."
  scp "$FILE" "$USER@$HOST:$DEST_DIR"
  
  if [[ $? -eq 0 ]]; then
    echo "✔ $FILE enviado com sucesso!"
  else
    echo "✘ Falha ao enviar $FILE"
  fi
done

echo "Fim do script."
