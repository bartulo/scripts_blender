#!/bin/bash

echo -e "Coordenada Latitud"
read latitud

echo -e "Coordenada Longitud"
read longitud

echo -e "Extensión (en km)"
read extension

echo -e "Resolucion PNOA"
read pnoa_res

echo -e "Resolucion MDT"
read mdt_res

lat=(1 0 -1)
long=(-1 0 1)
for i in 1 2 3
do
index_lat=$(($i - 1))
offset_lat=$((($extension * 975) * ${lat[${index_lat}]}))
for n in 1 2 3
do
index_long=$(($n - 1))
offset_long=$((($extension * 975) * ${long[${index_long}]}))
echo $offset_lat $offset_long

sur=$(($latitud - $extension*500 + $offset_lat))
norte=$(($latitud + $extension*500 + $offset_lat))
oeste=$(($longitud - $extension*500 + $offset_long))
este=$(($longitud + $extension*500 + $offset_long))

g.region n=$norte
g.region s=$sur
g.region w=$oeste
g.region e=$este

if [ $i == 2 ] && [ $n == 2 ]
  then 
    g.region nsres=$pnoa_res
    g.region ewres=$pnoa_res
  else
    low_res=`echo "${pnoa_res} * 2" | bc`
    g.region nsres=$low_res
    g.region ewres=$low_res
fi

r.out.gdal pnoa out=pnoa.tif type=UInt16
gdal_translate -ot Byte -of JPEG -expand rgb pnoa.tif pnoa_${i}_${n}.jpg
rm pnoa.tif
rm *.xml 

g.region nsres=$mdt_res
g.region ewres=$mdt_res

if [ $i == 2 ] && [ $n == 2 ]
  then 
    r.mapcalc "mdt_${extension}k = mdt*30" --overwrite
    r.colors mdt_${extension}k rules=rules.txt
    r.out.gdal mdt_${extension}k out=mdt_${i}_${n}.tif type=UInt16 -f
  else 
    r.mapcalc 'mdt_tmp = mdt*30'
    r.colors mdt_tmp rules=rules.txt
    r.out.gdal mdt_tmp out=mdt_${i}_${n}.tif type=UInt16 -f
    g.remove type=rast name=mdt_tmp -f
fi

echo $sur $este
done
done
