% Define the numerator and denominator coefficients
b = [1, -1/4];
a = [1, -1/3, 0, 1, 2/3];

% Compute the residues and poles
[r, p, k] = residue(b, a);

disp('Residues:');
disp(r);

disp('Poles:');
disp(p);

disp('Direct polynomial term:');
disp(k);