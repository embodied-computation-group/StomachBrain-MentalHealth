cd /mnt/fast_scratch/StomachBrain/data/allpreprocRest/
for file in *.tsv
do
    csv_file=${file%.*}.csv
    if [ -f "$csv_file" ]; then
        echo "$csv_file already exists, skipping conversion"
    else
        python /home/ignacio/vmp_pipelines_gastro/0B_tsv2csv.py < "$file" > "$csv_file"
        echo "Converted $file to $csv_file"
    fi
done
