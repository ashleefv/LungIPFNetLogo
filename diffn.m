% Parameters
Lx = 1.0;           % Length in x-direction cm
Ly = 1.0;           % Length in y-direction
Nx = 100;           % Number of grid points in x
Ny = 100;           % Number of grid points in y
D = 5e-7;           % Diffusion coefficient cm@/s
T = 3600;           % Total simulation time s
dt = 0.125;         % Time step

% Derived quantities
dx = Lx / (Nx - 1);
dy = Ly / (Ny - 1);
x = linspace(0, Lx, Nx);
y = linspace(0, Ly, Ny);
[X, Y] = meshgrid(x, y);

% Stability condition check

if dt > dx^2 * dy^2 / (2 * D * (dx^2 + dy^2))
    error('Time step too large for stability!');
end

% Initial condition: point source at center
u = zeros(Ny, Nx);
cx = round(Nx/2);
cy = round(Ny/2);
initialSourceTGFbeta = 5000;
lowTGFbetaThresh = 0.05 * initialSourceTGFbeta;
initialnumberofsources = 90;
for i = 1:initialnumberofsources
    cx = randi(Nx);
    cy = randi(Ny);
    u(cy,cx) = initialSourceTGFbeta  ; 
end
% Time stepping loop
nSteps = round(T / dt);
figure;
for n = 1:nSteps
    u_new = u;
    for i = 2:Ny-1
        for j = 2:Nx-1
            u_new(i,j) = u(i,j) + D * dt * ( ...
                (u(i+1,j) - 2*u(i,j) + u(i-1,j)) / dy^2 + ...
                (u(i,j+1) - 2*u(i,j) + u(i,j-1)) / dx^2 );
        end
    end
    % dirichlet BC
    u = u_new;
    u(:,[1 end]) = 0; u([1 end],:) = 0;

    % Optional: visualize every 100 steps
    if mod(n,100) == 0
        surf(X, Y, u/initialSourceTGFbeta, 'EdgeColor', 'none');
        title(['Time = ', num2str(n*dt/3600) ,' (hr)']);
        xlabel('x'); ylabel('y'); zlabel('u/initialSourceTGFbeta');
        zmin = lowTGFbetaThresh;
        zmax = initialSourceTGFbeta;
        %axis([x(1) x(end) y(1) y(end) zmin zmax])
        drawnow;
    end
end