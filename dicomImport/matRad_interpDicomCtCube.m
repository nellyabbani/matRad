function interpCt = matRad_interpDicomCtCube(origCt, origCtInfo, resolution, grid)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matRad function to interpolate a 3D ct cube to a different resolution
%
% call
%   interpCt = matRad_interpDicomCtCube(origCt, origCtInfo, resolution)
%
% input
%   origCt:         original CT as matlab 3D array
%   origCtInfo:     meta information about the geometry of the orgiCt cube
%   resolution:     target resolution [mm] in x, y, an z direction for the
%                   new cube
%   grid:           optional: externally specified grid vector
%
% output
%   interpCt:       interpolated ct cube as matlab 3D array
%
% References
%   -
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2015 the matRad development team.
%
% This file is part of the matRad project. It is subject to the license
% terms in the LICENSE file found in the top-level directory of this
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part
% of the matRad project, including this file, may be copied, modified,
% propagated, or distributed except according to the terms contained in the
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


coordsOfFirstPixel = [origCtInfo.ImagePositionPatient];

% set up grid vectors
x = coordsOfFirstPixel(1,1) + origCtInfo(1).ImageOrientationPatient(1) * ...
                              origCtInfo(1).PixelSpacing(1)*double([0:origCtInfo(1).Columns-1]) + .5*origCtInfo(1).PixelSpacing(1);
y = coordsOfFirstPixel(2,1) + origCtInfo(1).ImageOrientationPatient(5) * ...
                              origCtInfo(1).PixelSpacing(2)*double([0:origCtInfo(1).Rows-1]) + .5*origCtInfo(1).PixelSpacing(2);
z = coordsOfFirstPixel(3,:) + .5*origCtInfo(1).SliceThickness;

if exist('grid','var')
    xq = grid{1};
    yq = grid{2};
    zq = grid{3};
else
    xq = coordsOfFirstPixel(1,1)+.5*origCtInfo(1).PixelSpacing(1) + ...
         [0:origCtInfo(1).ImageOrientationPatient(1)*resolution.x:origCtInfo(1).ImageOrientationPatient(1)*origCtInfo(1).PixelSpacing(1)*double(origCtInfo(1).Columns-1)];
    yq = coordsOfFirstPixel(2,1)+.5*origCtInfo(1).PixelSpacing(2) + ...
         [0:origCtInfo(1).ImageOrientationPatient(5)*resolution.y:origCtInfo(1).ImageOrientationPatient(5)*origCtInfo(1).PixelSpacing(2)*double(origCtInfo(1).Rows-1)];
    zq = (coordsOfFirstPixel(3,1)+.5*origCtInfo(1).SliceThickness):resolution.z:(coordsOfFirstPixel(3,end)+.5*origCtInfo(3).SliceThickness);
end

% set up grid matrices - implicit dimension permuation (X Y Z-> Y X Z)
% Matlab represents internally in the first matrix dimension the
% ordinate axis and in the second matrix dimension the abscissas axis
[ Y,  X,  Z] = meshgrid(x,y,z);
[Yq, Xq, Zq] = meshgrid(xq,yq,zq);

% interpolate cube - cube is now stored in Y X Z 
interpCt.cube{1} = interp3(Y,X,Z,origCt,Yq,Xq,Zq);

% some meta information
interpCt.resolution = resolution;

interpCt.x = xq;
interpCt.y = yq;
interpCt.z = zq;

interpCt.cubeDim     = [numel(yq) numel(xq) numel(zq)];
interpCt.numOfCtScen = 1;
