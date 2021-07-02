for $BioSampleSet in doc(
  'biosample_set'
)/BioSampleSet
return concat(
  count(
    $BioSampleSet/BioSample
  ), codepoints-to-string(
    10
  )
)
