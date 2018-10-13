clear all; close all;
MaxDisp = 30000;
markSz  = 3;

%####################### MACROS ##########################
addpath('../../data/DIBCO/whole/img');
OutDir = './Howe';

if (~exist(OutDir,'dir'))
    mkdir(OutDir);
end

%####################### MACROS ##########################
DibcoTVs     = dir('../../data/DIBCO/whole/img');

x={};
for i = 1:size(DibcoTVs,1)
    x = [x; DibcoTVs(i).name];
end
DibcoTVs = x(3:end);

TVs  = DibcoTVs;

%####################### ENTER MAIN ##########################
for f = 1:size(TVs)
    
    iim   = imread(char(TVs(f)));

    if(size((size(iim)),2) == 3);
        img  = double(rgb2gray(iim));
    else
        img  = double(iim);
    end
    
    sr  = 23.2084;
    ct  = [5.2742e-004 0.3899];

    eimg = edge(img,'canny',ct);
    dx   = img(1:end-1,2:end)-img(1:end-1,1:end-1);
    dy   = img(2:end,1:end-1)-img(1:end-1,1:end-1);
    dvr  = divergence(dx,dy);

    img2 = (img-gsmooth(img,sr,3*sr,'mirror'));
    rms = sqrt(gsmooth(img2.^2,sr));
    himask = (img2./(rms+eps)>2);
    dvr(himask(1:end-1,1:end-1)) = -500;

    tvN       = strsplit(char(TVs(f)),'.');
    clustData = strcat(char(tvN(1)),'.clust');
    [im, in]  = size(img(1:end-1,1:end-1));
    
    if (exist(clustData,'file'))
        load(clustData,'-mat','p2cl');
        numClust = max(p2cl);
        clMembsCell = [];
        for cN = 1:numClust
            myMembers = numel(find(p2cl == cN));
            clMembsCell = [clMembsCell; myMembers];
        end
        [val, idx] = max(clMembsCell);
    else
        Y1  = img(1:end-1,1:end-1);
        Y2  = dx;
        Y3  = dy;

        Xpoints        = [reshape(Y1,1,[]);...                        
                            reshape(Y2,1,[]);...
                            reshape(Y3,1,[])];
        him = Y1;

        Lbw = Lbw0;
        [clCent,p2cl,clMembsCell] = MeanShiftCluster(Xpoints,Lbw);
        NoBiFurcation = 1;

        sFactor = floor(size(Xpoints,2)/ MaxDisp);
        
        while(NoBiFurcation)
            [val, idx] = max(clMembsCell);
            
            if ((( numel(him) - val) / (numel(him))) > perClSzTh )
                NoBiFurcation = 0;
                
                %figure; hold on;
                %S = 3*ones(1,(numel(him) - val)/sFactor);
                num = floor(val/sFactor);
                S = markSz*ones(1,num);
                C = repmat([0.5 0.5 1],num,1);
                ridx = randi([1,val], 1,num);
                
                xc = Xpoints(1,:); 
                rbxc = xc(p2cl == idx); 
                rbxc = rbxc(ridx);
                
                yc = Xpoints(2,:); 
                rbyc = yc(p2cl == idx); 
                rbyc = rbyc(ridx);
                
                zc = Xpoints(3,:); 
                rbzc = zc(p2cl == idx); 
                rbzc = rbzc(ridx);
                
                %scatter3(rbxc, rbyc, rbzc, S, C,'fill');
                
                num = floor((numel(him) - val)/sFactor);
                S = markSz*ones(1,num);
                %C = repmat([1 0 0],num,1);
                C = repmat([0.5 0.5 1],num,1);
                ridx = randi([1,(numel(him) - val)], 1,num);
                
                xc = Xpoints(1,:); 
                rbxc = xc(p2cl ~= idx); 
                rbxc = rbxc(ridx);
                
                yc = Xpoints(2,:); 
                rbyc = yc(p2cl ~= idx); 
                rbyc = rbyc(ridx);
                
                zc = Xpoints(3,:); 
                rbzc = zc(p2cl ~= idx); 
                rbzc = rbzc(ridx);
                
                %scatter3(rbxc, rbyc, rbzc, S, C,'fill');
                
                break;
            end
            Lbw = 0.5*Lbw;
            if(NoBiFurcation)
                [clCent,p2cl,clMembsCell] = MeanShiftCluster(Xpoints,Lbw);
            end
        end
        oldFolder = cd(ClstDataDir);
        save(clustData,'p2cl');
        cd(oldFolder);
    end
    
    dvr1 = dvr;
    Hfe = 2;
    wgt = 25;
    dvr1(reshape((p2cl == idx),im,in)) = -( 1/3 * Hfe);
    
    hc = ~((eimg(1:end-1,1:end-1)&(dy>0))|(eimg(2:end,1:end-1)&(dy<=0)));
    vc = ~((eimg(1:end-1,1:end-1)&(dx>0))|(eimg(1:end-1,2:end)&(dx<=0)));
    hc = hc(1:end-1,:);
    vc = vc(:,1:end-1);

    bimg = logical(imgcut3(Hfe-dvr1,Hfe+dvr1,wgt.*hc,wgt.*vc));
    bimg = bimg([1:end end],[1:end end]);
    
    eimg = NormalizeEdgeMap(eimg, eimg&bimg);
    
    wgt = 122.1634;

    eimg2 = edge(img,'canny',0);
    eimg = eimg|(eimg2&bimg);

    hc = ~((eimg(1:end-1,1:end-1)&(dy>0))|(eimg(2:end,1:end-1)&(dy<=0)));
    vc = ~((eimg(1:end-1,1:end-1)&(dx>0))|(eimg(1:end-1,2:end)&(dx<=0)));
    hc = hc(1:end-1,:);
    vc = vc(:,1:end-1);

    % redo binarization
    bimg = logical(imgcut3(1500-dvr,1500+dvr,wgt.*hc,wgt.*vc));
    bimg = bimg([1:end end],[1:end end]);
    nw = bimg&~bimg([1 1:end-1],:)&~bimg(:,[1 1:end-1]);
    bimg = bimg&~nw;
    bimg = ~bimg;
    
    oldFolder = cd(OutDir);
    tvN       = strsplit(char(TVs(f)),'.');
    oFile     = strcat(char(tvN(1)),'_MSCl.png');
    
    imwrite(bimg, oFile);
    
    cd(oldFolder);
end
