bs_reached=0;
export bs_chunk_size=500000;
date;
max_biosample_id_sci=`basex get_max_biosample_id.xq`;
date;
export max_biosample_id_int=$(printf "%.0f" $max_biosample_id_sci) ;
echo $max_biosample_id_int ;
while [ $bs_reached -le $max_biosample_id_int ]
do
  echo $bs_reached
  let start=bs_reached
  let bs_reached=bs_reached+bs_chunk_size
  date && \
  basex \
  -bmin_bs_id_val=${start} \
  -bmax_bs_id_val=${bs_reached} \
  harm_name_pipecatted_vals_needs_externals.xq > \
  chunks/harm_name_pipecatted_vals_needs_externals_${start}_${bs_reached}.tsv && \
  date
done