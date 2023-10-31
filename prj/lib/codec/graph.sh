tdir=__graph
name=codec

rm -rf $tdir
mkdir $tdir
cd $tdir
cmake --graphviz=$name.dot ..
dot -Tpng -O $name.dot