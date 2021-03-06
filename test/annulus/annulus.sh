levels="3 4 5 6"

if test x$donotrun != xtrue; then
    rm -f error
    for level in $levels; do
	if gerris2D -DLEVEL=$level $1 >> error; then :
	else
	    exit 1
	fi
    done
fi

if gnuplot <<EOF ; then :
    set term postscript eps color lw 3 solid 20 enhanced
    set output 'profile.eps'
    set xlabel 'Radius'
    r(x)=(x/4. + 0.375)
    v(r)=r*((0.5/r)*(0.5/r) - 1.)/((0.5/0.25)*(0.5/0.25) - 1.)
    t(r)=-(log(r)/log(2.) + 1.)/4.
    plot [0.25:0.5]\
         v(x) t 'Tangential velocity', \
         'end-4.txt' u (r(\$16)):7 ps 2 t '', \
         t(x) t 'Tracer', \
         'end-4.txt' u (r(\$16)):13 ps 2 t ''

    set output 'convergence.eps'
    set xlabel 'Spatial resolution'
    set ylabel 'Error norms'
    set logscale
    set grid
    set xtics 2
    set key spacing 1.5 bottom left
    ftitle(a,b) = sprintf("%.3g/x^{%4.2f}", exp(a), -b)
    f2(x)=a2+b2*x
    fit [3:]f2(x) 'error' u (log(2**\$1)):(log(\$3)) via a2,b2
    fm(x)=am+bm*x
    fit [3:]fm(x) 'error' u (log(2**\$1)):(log(\$4)) via am,bm
    plot [6:80]'error' u (2**\$1):3 t 'L2' w p ps 2,  exp(f2(log(x))) t ftitle(a2,b2), \
               'error' u (2**\$1):4 t 'Max' w p ps 2, exp(fm(log(x))) t ftitle(am,bm)
EOF
else
    exit 1
fi

if cat <<EOF | python ; then :
from check import *
from sys import *
if (Curve('error',1,4) - Curve('error.ref',1,4)).max() > 1e-6:
    exit(1)
EOF
else
   exit 1
fi
