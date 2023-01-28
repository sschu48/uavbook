%=========================================
% This file was created by Sean Schumacher
% Using the UAV Book for guidance
% Created 12-28-22
%
% Draws the MAV with points from Figure 2.14
% Ran in Simulink
%==========================================

function drawAircraft(uu)

    % process inputs to function
    pn          = uu(1);    % inertial North position
    pe          = uu(2);    % inertial East position
    pd          = uu(3);
    u           = uu(4);
    v           = uu(5);
    w           = uu(6);
    phi         = uu(7);    % roll angle
    theta       = uu(8);    % pitch angle
    psi         = uu(9);    % yaw angle
    p           = uu(10);   % roll rate
    q           = uu(11);   % pitch rate
    r           = uu(12);   % yaw rate
    t           = uu(13);   % time

    % define persistent variables
    persistent mav_handle;
    persistent Vertices
    persistent Faces
    persistent facecolors

    % first time function is called, initialize plot and persistent vars
    if t == 0
        figure(1), clf
        [Vertices, Faces, facecolors] = defineMAVBody;
        mav_handle = drawMAVBody(Vertices, Faces, facecolors, ...
                                 pn, pe, pd, phi, theta, psi, ...
                                 [], 'normal');
        title('MAV')
        xlabel('East')
        ylabel('North')
        zlabel('Height')
        view(32,47)
        axis([-10, 10, -10, 10, -10, 10]);
        hold on

    % at every other time step, redraw mav
    else
        drawMAVBody(Vertices, Faces, facecolors, ...
                    pn, pe, pd, phi, theta, psi, ...
                    mav_handle);
    end
end

%==========================================================================
% drawMAVBody
% return handle if 3rd argument is empty, otherwise use 3rd arg as handle
%==========================================================================

function handle = drawMAVBody(V, F, patchcolors, ...
                              pn, pe, pd, phi, theta, psi, ...
                              handle, mode)
    V = rotate(V', phi, theta, psi)';   % rotate mav
    V = translate(V', pe, pn, pd)';     % translate mav
    % transform vertices from NED to XYZ for MATLAB
    R = [
        0 1 0;
        1 0 0;
        0 0 -1];
    V = V*R;

    if isempty(handle)
        handle = patch('Vertices', V, 'Faces', F,...
                 'FaceVertexCData',patchcolors,...
                 'FaceColor','flat',...
                 'EraseMode', mode);
    else
        set(handle, 'Vertices', V, 'Faces', F);
        drawnow
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function XYZ = rotate(XYZ, phi, theta, psi)
    % define rotation matrix
    R_roll = [
            1, 0, 0;
            0, cos(phi), -sin(phi);
            0, sin(phi), cos(phi)];
    R_pitch = [
            cos(theta), 0, sin(theta);
            0, 1, 0;
            -sin(theta), 0, cos(theta)];
    R_yaw = [
            cos(psi), -sin(psi), 0;
            sin(psi), cos(psi), 0;
            0, 0, 1];
    R = R_roll * R_pitch * R_yaw;
    % rotate vertices
    XYZ = R * XYZ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% translate vertices by pn, pe, pd
function XYZ = translate(XYZ, pn, pe, pd)
    XYZ = XYZ + repmat([pn;pe;pd], 1, size(XYZ, 2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% define the vertices
function [V, F, colors] = defineMAVBody()


    % length of body paramters
    ul = 1; % unit length
    fuse_h = ul;
    fuse_w = ul;
    fuse_l1 = ul * 2;
    fuse_l2 = ul;
    fuse_l3 = ul * 4;
    wing_l = ul;
    wing_w = ul * 6;
    tail_h = ul;
    tail_l = ul;
    tail_w = ul * 2;
    
    V = [
        fuse_l1, 0, 0;                      % point 1
        fuse_l2, fuse_w/2, -fuse_h/2;       % point 2
        fuse_l2, -fuse_w/2, -fuse_h/2;      % point 3
        fuse_l2, -fuse_w/2, fuse_h/2;       % point 4
        fuse_l2, fuse_w/2, fuse_h/2;        % point 5
        -fuse_l3, 0, 0;                     % point 6
        0, wing_w/2, 0;                     % point 7
        -wing_l, wing_w/2, 0;               % point 8
        -wing_l, -wing_w/2, 0;              % point 9
        0, -wing_w/2, 0;                    % point 10
        -fuse_l3+tail_l, tail_w/2, 0;       % point 11
        -fuse_l3, tail_w/2, 0;              % point 12
        -fuse_l3+tail_l, -tail_w/2, 0;      % point 13
        -fuse_l3, -tail_w/2, 0;             % point 14
        -fuse_l3+tail_l, 0, 0;              % point 15
        -fuse_l3, 0, -tail_h;               % point 16
    ];

    % define faces as a list of Vertices numbered above
    F = [
            1, 2, 3;                        % front fuse top
            1, 3, 4;                        % front fuse left
            1, 2, 4;                        % front fuse right
            1, 5, 4;                        % front fuse bottom
            2, 3, 6;                        % fuse top
            3, 4, 6;                        % fuse left
            2, 5, 6;                        % fuse right
            5, 4, 3;                        % fuse bottom
            15, 6, 16;                      % tail 
            7, 8, 9;                        % wing 1
            7, 9, 10;                       % wing 2
        ];

    % define colors for each face
    myred = [1, 0, 0];
    mygreen = [0 1, 0];
    myblue = [0, 0, 1];
    myyellow = [1, 1, 0];
    mycyan = [0, 1, 1];

    colors = [
            myyellow;   % front fuse top
            myyellow;   % front fuse left
            myyellow;   % front fuse right
            myyellow;   % front fuse bottom
            myblue;     % fuse top
            myblue;     % fuse left
            myblue;     % fuse right
            myblue;     % fuse bottom
            mygreen;    % tail
            myred;      % wing 1
            myred;      % wing 2
        ];
end
