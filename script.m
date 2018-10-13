%%
gtDir     = 'C:\Users\kalay451\Desktop\Literature\HTR\ImagAnalys\Orig-TVs\DIBCO\GT\';
opDirMSCl = 'C:\Users\kalay451\Desktop\Literature\HTR\ImagAnalys\Orig-TVs\Output\Expt14\';
opDirHowe = 'C:\Users\kalay451\Desktop\Literature\HTR\ImagAnalys\Orig-TVs\Output\NHowe\';

%####################### MACROS ##########################
DibcoTVs  = dir('C:\Users\kalay451\Desktop\Literature\HTR\ImagAnalys\Orig-TVs\DIBCO\Images');

x={};
for i = 1:size(DibcoTVs,1)
    x = [x; DibcoTVs(i).name];
end
DibcoTVs = x(3:end);

TVs  = DibcoTVs;

oldFolder = cd(opDirMSCl);
fp = fopen('DIBCO_Scores.txt', 'w');
fprintf(fp, '==============MSCl vs Howe==============\n');
cd(oldFolder);

for f = 51:size(TVs)
    tvN    = strsplit(char(TVs(f)),'.');
    
    if (exist(strcat(gtDir,char(tvN(1)),'_GT.tiff'),'file'))
        gtFile = strcat(gtDir,char(tvN(1)),'_GT.tiff');
    else
        if (exist(strcat(gtDir,char(tvN(1)),'_GT.tif'),'file'))
            gtFile = strcat(gtDir,char(tvN(1)),'_GT.tif');
        else
            gtFile = strcat(gtDir,char(tvN(1)),'_GT.tiff/tif file missing');
            disp(gtFile);
        end
    end

    if (exist(strcat(opDirMSCl,char(tvN(1)),'_MSCl.png'),'file'))
        msclFile = strcat(opDirMSCl,char(tvN(1)),'_MSCl.png');
    else
        if (exist(strcat(opDirMSCl,char(tvN(1)),'_MSCl.png'),'file'))
            msclFile = strcat(opDirMSCl,char(tvN(1)),'_MSCl.png');
        else
            msclFile = strcat(opDirMSCl,char(tvN(1)),'_MSCl.png file missing');
            disp(msclFile);
        end
    end

    if (exist(strcat(opDirHowe,char(tvN(1)),'_Howe.png'),'file'))
        howeFile = strcat(opDirHowe,char(tvN(1)),'_Howe.png');
    else
        if (exist(strcat(opDirHowe,char(tvN(1)),'_Howe.png'),'file'))
            howeFile = strcat(opDirHowe,char(tvN(1)),'_Howe.png');
        else
            howeFile = strcat(opDirHowe,char(tvN(1)),'_Howe.png file missing');
            disp(howeFile);
        end
    end
    
    NHTargs  = strcat(gtFile, {' '}, howeFile);
    MSCTargs = strcat(gtFile, {' '}, msclFile);
    
    [sysN, cmdN] = system(['C:\Users\kalay451\Desktop\Literature\HTR\ImagAnalys\Orig-TVs\HDIBCO12_metrics.exe ',char(NHTargs)]);
    [sysM, cmdM] = system(['C:\Users\kalay451\Desktop\Literature\HTR\ImagAnalys\Orig-TVs\HDIBCO12_metrics.exe ',char(MSCTargs)]);
    
    fprintf(fp, 'File %d: %s \n', f, char(TVs(f)));
    fprintf(fp, 'Howe Score: %s', cmdN);
    fprintf(fp, 'MSCl Score: %s\n', cmdM);

end
fclose(fp);
