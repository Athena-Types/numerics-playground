fd -e fpcore . ../benchmarks -x bash -c './_build/default/bin/main.exe ../benchmarks/{} > ../benchmarks/{}.paired'
fd -t e -e paired . ../benchmarks -x rm {}
