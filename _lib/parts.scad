{//bearing
module bearing(bearing_radius=bearing_radius, bearing_bore=bearing_bore, bearing_thick=bearing_thick)
{
    wall_thick = (bearing_radius-bearing_bore)/4;
    color(color_metal)
    rotate_extrude($fn=2*pi*bearing_radius/res)
    {
        translate([bearing_radius-wall_thick, 0, 0])
        square([wall_thick, bearing_thick]);
        translate([bearing_bore, 0, 0])
        square([wall_thick, bearing_thick]);
    }
        
    color(color_rubber)
    rotate_extrude($fn=2*pi*(bearing_bore+3*wall_thick)/res)
    {
        translate([bearing_bore+wall_thick, 0, 0])
        square([2*wall_thick, bearing_thick]);
    }
       
}
}

include <_lib/bolt_sizes.scad>
{//bolts and nuts
{//modules
module screw_thread(thread_diameter=thread_radius*2,pitch=pitch,thread_angle=thread_angle,threaded_length=threadeded_length,rs=3.141592/2,cs=0)//cs is countersink from -2 --> 2 rs is resolution
{
    or=thread_diameter/2;
    ir=or-pitch/2*cos(thread_angle)/sin(thread_angle);
    pf=2*PI*or;
    sn=floor(pf/rs);
    thread_anglexy=360/sn;
    ttn=round(threaded_length/pitch+1);
    zt=pitch/sn;

    intersection()
    {
        if (cs >= -1)
        {
           thread_shape(cs,threaded_length,or,ir,sn,pitch);
        }

        full_thread(ttn,pitch,sn,zt,thread_anglexy,or,ir);
    }
}
module thread_shape(cs,threaded_length,or,ir,sn,pitch)
{
    if ( cs == 0 )
    {
        cylinder(h=threaded_length, r=or, $fn=sn, center=false);
    }
    else
    {
        union()
        {
            translate([0,0,pitch/2])
              cylinder(h=threaded_length-pitch+0.005, r=or, $fn=sn, center=false);

            if ( cs == -1 || cs == 2 )
            {
                cylinder(h=pitch/2, r1=ir, r2=or, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=pitch/2, r=or, $fn=sn, center=false);
            }

            translate([0,0,threaded_length-pitch/2])
            if ( cs == 1 || cs == 2 )
            {
                  cylinder(h=pitch/2, r1=or, r2=ir, $fn=sn, center=false);
            }
            else
            {
                cylinder(h=pitch/2, r=or, $fn=sn, center=false);
            }
        }
    }
}

module full_thread(ttn,pitch,sn,zt,thread_anglexy,or,ir)
{
  if(ir >= 0.2)
  {
    for(i=[0:ttn-1])
    {
        for(j=[0:sn-1])
			assign( pt = [	[0,                  0,                  i*pitch-pitch            ],
                        [ir*cos(j*thread_anglexy),     ir*sin(j*thread_anglexy),     i*pitch+j*zt-pitch       ],
                        [ir*cos((j+1)*thread_anglexy), ir*sin((j+1)*thread_anglexy), i*pitch+(j+1)*zt-pitch   ],
								[0,0,i*pitch],
                        [or*cos(j*thread_anglexy),     or*sin(j*thread_anglexy),     i*pitch+j*zt-pitch/2     ],
                        [or*cos((j+1)*thread_anglexy), or*sin((j+1)*thread_anglexy), i*pitch+(j+1)*zt-pitch/2 ],
                        [ir*cos(j*thread_anglexy),     ir*sin(j*thread_anglexy),     i*pitch+j*zt          ],
                        [ir*cos((j+1)*thread_anglexy), ir*sin((j+1)*thread_anglexy), i*pitch+(j+1)*zt      ],
                        [0,                  0,                  i*pitch+pitch            ]	])
        {
            polyhedron(points=pt,
              		  triangles=[	[1,0,3],[1,3,6],[6,3,8],[1,6,4],
											[0,1,2],[1,4,2],[2,4,5],[5,4,6],[5,6,7],[7,6,8],
											[7,8,3],[0,2,3],[3,2,7],[7,2,5]	]);
        }
    }
  }
  else
  {
    echo("pitchep Degrees too agresive, the thread will not be made!!");
    echo("Try to increase de value for the degrees and/or...");
    echo(" decrease the pitch value and/or...");
    echo(" increase the outer diameter value.");
  }
}
}

module M_cap(size, length, non_threaded=0)
{
    echo(size);
    translate([0, 0, non_threaded+size[2]])screw_thread(2*size[0], size[3], size[4], length-non_threaded, res, 2);
    translate([0, 0, size[2]])cylinder_c(non_threaded, size[0], chamfer=0, chamfer2=size[3]/2, res=res);
    cylinder_c(size[2], size[1], size[3], res);
    
}
module M_nut(size)
{   
    difference()
    {
        cylinder_c(size[1], size[0], chamfer=size[3], res=size[0]*2*pi/6);
        screw_thread(2*size[2], size[3], size[4], 2*size[0], res, 0);
    }
}
/*
res=1;
pi=3.14;
include <_lib/bolt_sizes.scad>
include <_lib/fillet_generator.scad>
//M_cap(M8_cap, 50, 20);
//cylinder_c(10, 8, chamfer=1.25, res=res);
M_nut(M8_nut);
*/
}
