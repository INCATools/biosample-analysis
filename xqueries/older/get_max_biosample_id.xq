max(
  for $bss in doc(
     'biosample_set' 
  )/BioSampleSet
return data(
    $bss/BioSample/@id
  )
)
