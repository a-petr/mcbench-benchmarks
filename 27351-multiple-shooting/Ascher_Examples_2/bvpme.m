function y=bvpme(t,x,flag,U)
y =[0.5*x(1)*(x(3)-x(1))/x(2);
    -0.5*(x(3)-x(1));
    (0.9-1000*(x(3)-x(5))-0.5*x(3)*(x(3)-x(1)))/x(4);
    0.5*(x(3)-x(1));
    -100*(x(5)-x(3));];
end

