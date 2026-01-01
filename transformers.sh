#!/bin/bash

if [ ! -d "../results" ]; then
    mkdir ../results
fi

seq_len=336
label_len=48
pred_lens=(96 192 336 720)

# Configuration: dataset_name, csv_file, num_features (for enc_in, dec_in, c_out)
datasets=(
  "air-pollution,air-pollution.csv,8"
  "microsoft-stock,microsoft-stock.csv,6"
  "household-power,household_power_consumption_hourly_clean.csv,7"
  "qps,QPS_clean.csv,10"
  "sales,sales_clean.csv,8"
  "wind-power-generation,wind-power-generation.csv,9"
)

# Run each model
for model_name in Autoformer FEDformer
do

  # Run each dataset
  for dataset_config in "${datasets[@]}"
  do
    IFS=',' read -r dataset_name data_file num_features <<< "$dataset_config"
    
    if [ ! -d "../results/$dataset_name" ]; then
      mkdir ../results/$dataset_name
    fi
    
    # Run each prediction horizon
    for pred_len in "${pred_lens[@]}"
    do
      echo "Running $model_name on $dataset_name with pred_len=$pred_len"
      
      if [ "$model_name" = "FEDformer" ]; then
        cd FEDformer
        python -u run.py \
          --is_training 1 \
          --data_path $data_file \
          --task_id ${dataset_name}_${seq_len}_${pred_len} \
          --model $model_name \
          --data custom \
          --features M \
          --seq_len $seq_len \
          --label_len $label_len \
          --pred_len $pred_len \
          --enc_in $num_features \
          --dec_in $num_features \
          --c_out $num_features \
          --e_layers 2 \
          --d_layers 1 \
          --factor 3 \
          --des 'Exp' \
          --itr 1 \
          >../../results/$dataset_name/${model_name}_${dataset_name}_${seq_len}_${pred_len}.log 2>&1
        cd ..
      else
        python -u run_longExp.py \
          --is_training 1 \
          --root_path ./dataset/ \
          --data_path $data_file \
          --model_id ${dataset_name}_${seq_len}_${pred_len} \
          --model $model_name \
          --data custom \
          --features M \
          --seq_len $seq_len \
          --label_len $label_len \
          --pred_len $pred_len \
          --enc_in $num_features \
          --dec_in $num_features \
          --c_out $num_features \
          --e_layers 2 \
          --d_layers 1 \
          --factor 3 \
          --des 'Exp' \
          --itr 1 \
          >../results/$dataset_name/${model_name}_${dataset_name}_${seq_len}_${pred_len}.log 2>&1
      fi
      
    done
    
  done
  
done