function [r_e__e_b] = llh2xyz(L_b, lambda_b, h_b)
%
% FUNCTION DESCRIPTION:
%   Converts geodetic curvilinear coordinates to ECEF rectangular coordinates
%
% INPUTS:
%   L_b		 = Geodetic body latitude (radians)
%	lambda_b = Geodetic body longitude (radians)
%	h_b		 = Geodetic height (meters)
%
% OUTPUTS:
%   r_e__e_b = 3-tupple vector describing ECEF coordinates of the body frame
%			   origin wrt the e-frame origin coordinatized in the e-frame (meters)
%
% NOTES:
%   - L_b refers to longitude East.  If using West negate value
%
% REFERENCE:
%   "Nav Sys" by P. Groves Eqn. 2.70 page 42
%   

e = 0.0818191908425;        % Eccentricity
R0 = 6378137.0;             % Equatorial radius (meters)

RE = R0 / sqrt(1 - e^2*(sin(L_b))^2);  % Transverse radius of curvature (m)

% The body position in ECEF coordinates: Groves: Eqn 2.70 page 41\2
r_e__e_b = [(RE + h_b) * cos(L_b) * cos(lambda_b); ...    % (meters)
            (RE + h_b) * cos(L_b) * sin(lambda_b); ...
            ((1 - e^2)*RE + h_b)  * sin(L_b)];
end