#!/bin/bash

TEMPLATE="template-sensores.py"
HECTARES_POR_RASP=500

chmod +x "$0"
chmod +x "send_files.sh"

echo "✅ Permissão de execução garantida (ou já existia) para: $0"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "❌ Arquivo '$TEMPLATE' não encontrado!"
  exit 1
fi

# Detecta o último número de arquivo existente
ultimo_existente=$(ls sensor_rasp_*.py 2>/dev/null | sed -n 's/sensor_rasp_\([0-9]\{3\}\)\.py/\1/p' | sort -n | tail -n 1)

if [[ -z "$ultimo_existente" ]]; then
  proximo=1
else
  proximo=$((10#$ultimo_existente + 1))
fi

echo "🔍 Último arquivo existente: ${ultimo_existente:-nenhum}. Próximo: $(printf "%03d" $proximo)"

echo "Você quer informar:"
echo "1 - A quantidade de Raspberries"
echo "2 - A área total em hectares (1 Rasp a cada ${HECTARES_POR_RASP} ha)"
read -p "Escolha [1/2]: " modo

if [[ "$modo" == "1" ]]; then
  read -p "Digite a quantidade de Raspberries a adicionar: " qtd
elif [[ "$modo" == "2" ]]; then
  read -p "Digite a área total em hectares: " area
  qtd=$(( (area + HECTARES_POR_RASP - 1) / HECTARES_POR_RASP ))
  echo "➡️  Será necessário adicionar $qtd raspberries para cobrir $area hectares."
else
  echo "❌ Opção inválida."
  exit 1
fi

echo "⏳ Gerando $qtd novos arquivos a partir de sensor_rasp_$(printf "%03d" $proximo).py..."

for ((i=0; i<qtd; i++)); do
  n=$((proximo + i))
  nome="RASP_$(printf "%03d" $n)"
  arquivo_saida="sensor_rasp_$(printf "%03d" $n).py"
  sed "s/^raspberry_name *= *None/raspberry_name = '${nome}'/" "$TEMPLATE" > "$arquivo_saida"
  chmod a=rx "$arquivo_saida"
  echo "✅ Criado: $arquivo_saida (nome: ${nome})"
done

echo "🎉 Todos os arquivos foram gerados com sucesso!"