function eimg1 = NormalizeEdgeMap(eimg, eimg0)
    eimg1      = 0*eimg0;
    while(1)
        [~,icd]   = ixneighbors(eimg0, eimg0);
        eimg1(icd) = 1;
        eimg1      = (eimg & eimg1);
        if(max(max(xor(eimg1, eimg0))))
            eimg0 = eimg1;
        else
            break;
        end
    end
end