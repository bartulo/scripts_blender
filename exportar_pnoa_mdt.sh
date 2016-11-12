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

sur=$(($latitud - $extension*500))
norte=$(($latitud + $extension*500))
este=$(($longitud + $extension*500))
oeste=$(($longitud - $extension*500))

g.region n=$norte
g.region s=$sur
g.region e=$este
g.region w=$oeste

g.region nsres=$pnoa_res
g.region ewres=$pnoa_res

r.out.gdal pnoa out=pnoa.tif type=UInt16
gdal_translate -ot Byte -of JPEG -expand rgb pnoa.tif pnoa.jpg

g.region nsres=$mdt_res
g.region ewres=$mdt_res

r.mapcalc 'mdt_tmp = mdt*30'
r.colors mdt_tmp rules=rules.txt

r.out.gdal mdt_tmp out=mdt.tif type=UInt16 -f
g.remove type=rast name=mdt_tmp -f
