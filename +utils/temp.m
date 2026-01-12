img=images_filt{23};
height=size(img,1);
width=size(img,2);
w=zeros([16,16]);
cellsize=1024/16;
for x=1:16
    for y=1:16
        w(y,x)=var(img((1:cellsize)+(y-1)*cellsize,(1:cellsize)+(x-1)*cellsize),1,"all");
    end
end