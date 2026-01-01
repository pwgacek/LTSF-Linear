#!/bin/bash

if [ ! -d "../results" ]; then
    mkdir ../results
fi

seq_len=336
model_name=Naive
pred_lens=(96 192 336 720)

# Configuration: dataset_name, csv_file, batch_size
datasets=(
  "air-pollution,air-pollution.csv,16"
  "microsoft-stock,microsoft-stock.csv,16"
  "household-power,household_power_consumption_hourly_clean.csv,16"
  "qps,QPS_clean.csv,16"
  "sales,sales_clean.csv,16"
  "wind-power-generation,wind-power-generation.csv,16"
)

# Run each dataset
for dataset_config in "${datasets[@]}"
do
  IFS=',' read -r dataset_name data_file batch_size <<< "$dataset_config"
  
  if [ ! -d "../results/$dataset_name" ]; then
    mkdir ../results/$dataset_name
  fi
  
  # Run each prediction horizon
  for pred_len in "${pred_lens[@]}"
  do
    echo "Running $dataset_name with pred_len=$pred_len"
    
    python -u run_stat.py \
      --is_training 1 \
      --root_path ./dataset/ \
      --data_path $data_file \
      --model_id ${dataset_name}_${seq_len}_${pred_len} \
      --model $model_name \
      --data custom \
      --features M \
      --seq_len $seq_len \
      --pred_len $pred_len \
      --des 'Exp' \
      --itr 1 --batch_size $batch_size \
      >../results/$dataset_name/${model_name}_${dataset_name}_${seq_len}_${pred_len}.log 2>/dev/null
    
  done
  
done
