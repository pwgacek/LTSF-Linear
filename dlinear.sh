#!/bin/bash


if [ ! -d "../results" ]; then
    mkdir ../results
fi

seq_len=336
model_name=DLinear
pred_lens=(96 192 336 720)

# Configuration: dataset_name, csv_file, enc_in, batch_size, learning_rate, freq
datasets=(
  "air-pollution,air-pollution.csv,8,16,0.01,h"
  "microsoft-stock,microsoft-stock.csv,6,16,0.01,d"
  "household-power,household_power_consumption_hourly_clean.csv,7,16,0.01,h"
  "qps,QPS_clean.csv,10,16,0.01,t"
  "sales,sales_clean.csv,8,16,0.01,h"
  "wind-power-generation,wind-power-generation.csv,9,16,0.01,h"
)

# Run each dataset
for dataset_config in "${datasets[@]}"
do
  IFS=',' read -r dataset_name data_file enc_in batch_size learning_rate freq <<< "$dataset_config"
  
  if [ ! -d "../results/$dataset_name" ]; then
    mkdir ../results/$dataset_name
  fi
  
  # Run each prediction horizon
  for pred_len in "${pred_lens[@]}"
  do
    echo "Running $dataset_name with pred_len=$pred_len"
    
    python -u run_longExp.py \
      --is_training 1 \
      --root_path ./dataset/ \
      --data_path $data_file \
      --model_id ${dataset_name}_${seq_len}_${pred_len} \
      --model $model_name \
      --data custom \
      --features M \
      --seq_len $seq_len \
      --pred_len $pred_len \
      --enc_in $enc_in \
      --freq $freq \
      --des 'Exp' \
      --itr 1 --batch_size $batch_size --learning_rate $learning_rate \
      >../results/$dataset_name/${model_name}_${dataset_name}_${seq_len}_${pred_len}.log 2>&1
    
  done
  
done