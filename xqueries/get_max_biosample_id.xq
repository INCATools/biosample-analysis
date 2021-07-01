max(
  for $bss in doc(
     'biosample_set_basex'
  )/BioSampleSet
return data(
    $bss/BioSample/@id
  )
)
