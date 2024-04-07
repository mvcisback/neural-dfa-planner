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
	bitarray = pkgs.python3Packages.buildPythonPackage rec {
          pname = "bitarray";
	  version = "2.9.2";
	  format = "setuptools";
	  src = pkgs.python3Packages.fetchPypi rec {
            inherit pname version format;
	    sha256 = "a8f286a51a32323715d77755ed959f94bef13972e9a2fe71b609e40e6d27957e";
	  };
	  nativeBuildInputs = [
	    pkgs.python3
            pkgs.buildPackages.python3Packages.cffi  # Example dependency for CFFI-based extensions
            pkgs.buildPackages.python3Packages.setuptools
            pkgs.buildPackages.python3Packages.setuptools-scm
	    pkgs.buildPackages.python3Packages.wheel
	  ];
	  setupPyBuildFlags = [ "--inplace" ];
	};
        dfa = pkgs.python3Packages.buildPythonPackage rec {
          pname = "dfa";
          version = "4.6.3";
          format = "wheel";
          src = pkgs.python3Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "b4d511f73eb1588a391cc4a032362c836053963a17aa4bc58b40c59a39ea639a";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            pkgs.python311Packages.attrs
            pkgs.python311Packages.funcy
            pkgs.python311Packages.pydot
            pkgs.python311Packages.bidict
            bitarray
          ];
        };

        py-aiger = pkgs.python3Packages.buildPythonPackage rec {
          pname = "py_aiger";
          version = "6.2.3";
          format = "wheel";
          src = pkgs.python3Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "837bcd9f49b5a945e5877126f3238e08731d32d545fab05b2146c776dca9c45c";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            pkgs.python311Packages.attrs
            pkgs.python311Packages.funcy
            pkgs.python311Packages.pydot
            pkgs.python311Packages.pyrsistent
            pkgs.python311Packages.sortedcontainers
            pkgs.python311Packages.bidict
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
        python-env = pkgs.python3.withPackages (pyPkgs: with pyPkgs; [
          equinox
          jax
          jaxlib-bin
          numpy
          pandas
          py-aiger
	  pkgs.python3Packages.pip
	  dfa
        ]);

        name = "jax-equinox-basics";
      in pkgs.mkShell {
        inherit name;

        packages = [
          python-env
          pkgs.python311Packages.flit
          pkgs.python311Packages.ptpython
        ];
      };
    });
}
