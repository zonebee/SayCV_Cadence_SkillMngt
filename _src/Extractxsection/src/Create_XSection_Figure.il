;Written by Leon Lee. 2006/02/22
;Modified By Jonathan Dumaresq. 2008/07/17
; Use the new API for 16.x
; Extract XSection
;					Copper Layer, interlayer and thinkness of it.
; USE at your own risk. This is my first skill program.
; to use it, Juste type XSection2 in your skill windows. 

axlCmdRegister( "XSection2" `XSection2 ?cmdType "interactive")

defun( XSection2 ()
  stack_layer="MANUFACTURING/STACKUP_FIGURE"
  axlClearSelSet()
  Display=axlVisibleGet()
  axlVisibleDesign(nil)
  axlVisibleLayer(stack_layer t)
  axlDBRefreshId(axlDBGetDesign())
  axlSetFindFilter(?enabled '(noall shapes text) ?onButtons '(noall shapes text))
  axlDeleteObject(axlGetSelSet(axlAddSelectAll()))
  axlVisibleSet(Display)
;  axlShell("redisplay")
l_layer=axlGetXSection()
nbLayer = length(l_layer)
printf("nombre de couche: %d\n" nbLayer)
;printf("%L" l_layer)


nLayer=nil
declare( layer[nbLayer])
arrayp(layer)
for(lay 0 nbLayer-1 layer[lay]=car( nth( lay l_layer))
nLayer=append(nLayer list(lay+1 layer[lay]))
printf("%d  %s \n" lay+1 layer[lay])

Unit=car(axlDBGetDesignUnits())
	case(Unit
	("millimeters" u=1)
	("mils" u=40)
	("inches" u=0.04)
	("microns" u=1000)
	("centimeters" u=0.1)
	);end case
L=66*u	
H=-1*(5+nbLayer*4)*u

axlClearDynamics()
mypath = axlPathStart(list( 0:0 L:0 L:H 0:H 0:0))
axlAddSimpleMoveDynamics(0:0 mypath "path" ?ref_point 0:0)

);for
printf("Enter a point to place the X-Section Figure...\n")

if(axlIsLayer(stack_layer)==nil then
axlLayerCreateNonConductor(stack_layer)
);if
(axlUIWRedraw nil)
axlVisibleLayer(stack_layer t)


pointStart=nil
declare( point[nbLayer])
declare( bBox[nbLayer])
declare( layerName[nbLayer])

pointStart=axlEnterPoint()
Px=xCoord(pointStart)
Py=yCoord(pointStart)

totalThickness = 0;
for(p 1 nbLayer-2
	if(car( nth( p l_layer)) == "" then
		point[p]=list(Px+37*u Py-(p+2)*4*u)
		bBox[p]=list(list(Px+10*u Py-(p+2.5)*4*u) list(Px+35*u Py-(p+2)*4*u+4.2*u))
		layerName[p] = strcat( nth(1 nth( p l_layer)) " (" nth(3 nth( p l_layer)) ")") 
		myorient=make_axlTextOrientation(?textBlock "4",?rotation 0., ?mirrored nil, ?justify "left")
		axlDBCreateText(layerName[p], point[p], myorient, stack_layer,nil)
	else	
		point[p]=list(Px+45*u Py-(p+2)*4*u)
		bBox[p]=list(list(Px+5*u Py-(p+1.9)*4*u) list(Px+40*u Py-(p+1.9)*4*u+1.5*u))
		layerName[p]= strcat( car( nth( p l_layer)) " (" nth(3 nth( p l_layer)) ")") 
		myorient=make_axlTextOrientation(?textBlock "4",?rotation 0., ?mirrored nil, ?justify "left")
		axlDBCreateText(layerName[p], point[p], myorient, stack_layer,nil)

		);if
	axlDBCreateRectangle(bBox[p],t, stack_layer)
		totalThickness = totalThickness + atof(nth(3 nth( p l_layer)))
	 );for
	printf("total thickness = %f\n" totalThickness)
	axlDBCreateText("STACK_UP:",list(Px+3*u Py-4*u), myorient, stack_layer,nil)
;  axlDBCreateRectangle(list(list(Px Py) list(Px+100*u yCoord(point[nbLayer-1])-5*u)), nil, stack_layer)
sprintf(sTotalThickness, "%f" totalThickness)
	axlDBCreateText(strcat("Total Thickness: " sTotalThickness ),list(Px+3*u Py-4*u*(nbLayer+1)), myorient, stack_layer,nil)
);defun 