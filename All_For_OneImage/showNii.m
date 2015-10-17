
function showNii(niiData, z)
    maxVal = max(max(max(niiData)));
    imshow(niiData(:,:,z)',[0 maxVal]);
end



