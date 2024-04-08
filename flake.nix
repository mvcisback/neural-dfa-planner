{
  description = "An awesome machine-learning project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    overlays.dev = nixpkgs.lib.composeManyExtensions [
      inputs.ml-pkgs.overlays.jax-family
    ];
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let 
       bitarray = pkgs.python310Packages.buildPythonPackage rec {
           pname = "bitarray";
           version = "2.9.2";
           format = "setuptools";
           src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "a8f286a51a32323715d77755ed959f94bef13972e9a2fe71b609e40e6d27957e";
           };
           nativeBuildInputs = [
             pkgs.python3
             pkgs.buildPackages.python310Packages.cffi  # Example dependency for CFFI-based extensions
             pkgs.buildPackages.python310Packages.setuptools
             pkgs.buildPackages.python310Packages.setuptools-scm
             pkgs.buildPackages.python310Packages.wheel
           ];
           setupPyBuildFlags = [ "--inplace" ];
        };

        dfa = pkgs.python310Packages.buildPythonPackage rec {
          pname = "dfa";
          version = "4.6.3";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "b4d511f73eb1588a391cc4a032362c836053963a17aa4bc58b40c59a39ea639a";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            pkgs.python310Packages.attrs
            pkgs.python310Packages.funcy
            pkgs.python310Packages.pydot
            pkgs.python310Packages.bidict
            bitarray
          ];
        };

        py-aiger = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger";
          version = "6.2.3";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "837bcd9f49b5a945e5877126f3238e08731d32d545fab05b2146c776dca9c45c";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            pkgs.python310Packages.attrs
            pkgs.python310Packages.funcy
            pkgs.python310Packages.pydot
            pkgs.python310Packages.pyrsistent
            pkgs.python310Packages.sortedcontainers
            pkgs.python310Packages.bidict
          ];
        };

        py-aiger-bv = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_bv";
          version = "4.7.7";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "4e06bf68f0614c2c1db1f675923754c0e2a917182cde74fa2f47b0a08ed1a31c";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [ py-aiger ];
        };

        ply310 = pkgs.python310Packages.buildPythonPackage rec {
          pname = "ply";
          version = "3.10";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version;
            sha256 = "96e94af7dd7031d8d6dd6e2a8e0de593b511c211a86e28a9c9621c275ac8bacb";
          };
          buildInputs = [
            pkgs.python310Packages.pip
            pkgs.python310Packages.setuptools
            pkgs.python310Packages.wheel
          ];
        };


        astutils = pkgs.python310Packages.buildPythonPackage rec {
          pname = "astutils";
          version = "0.0.5";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version;
            sha256 = "ae731d6d0c2a12577597336eb8680d579b9cd0916e9fbb75b0643e16ce13d065";
          };
          buildInputs = [
            pkgs.python310Packages.pytest
            pkgs.python310Packages.pip
          ];
          propagatedBuildInputs = [ ply310 ];
        };


        dd = pkgs.python310Packages.buildPythonPackage rec {
          pname = "dd";
          version = "0.5.7";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "00d56402a9aa98137de87e718c4ddec259135c022c4f83de7a54b8e94b9d5690";
            python = "cp310";
            abi = "cp310";
            platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
            dist = python;
          };
          propagatedBuildInputs = [
            pkgs.python310Packages.networkx
            astutils
            pkgs.python310Packages.psutil
          ];
        };


        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "7.5" "8.6" ];
            cudaForwardCompat = false;
          };
          overlays = [ self.overlays.dev ];
        };
    in {
      devShells.default = let
        python-env = pkgs.python310.withPackages (pyPkgs: with pyPkgs; [
          equinox
          jax
          jaxlib-bin
          numpy
          pandas
          py-aiger
          py-aiger-bv
          dd
	      #pkgs.python3Packages.pip
          #dfa
        ]);

        name = "jax-equinox-basics";
      in pkgs.mkShell {
        inherit name;

        packages = [
          python-env
          pkgs.python310Packages.flit
          pkgs.python310Packages.ptpython
        ];
      };
    });
}
