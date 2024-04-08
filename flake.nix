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

        py-aiger-bdd = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_bdd";
          version = "3.1.2";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "339b31c88b75bd1dfaf57a769023ca799f613dbe11d213c6425daf7eaf7ed077";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            dd
            py-aiger
          ];
        };

        bdd2dfa = pkgs.python310Packages.buildPythonPackage rec {
          pname = "bdd2dfa";
          version = "1.0.10";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "04a63ceab7d5c844bdd422b69b49148f307ea78cd3ecd876f68da058a9b47a75";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [ dfa pkgs.python310Packages.attrs ];
        };

        mdd = pkgs.python310Packages.buildPythonPackage rec {
          pname = "mdd";
          version = "0.3.7";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "bf51b6ca3ea3cf1860a1cac9b8b9255384c96f1ee645424ff081f5340f30aa6e";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            bdd2dfa
            dd
            py-aiger
            py-aiger-bv
            py-aiger-bdd
            pkgs.python310Packages.funcy
            pkgs.python310Packages.networkx
          ];
        };

        py-aiger-ptltl = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_ptltl";
          version = "3.1.2";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "cb64d2a1699cbb1a8940d619912303079a958726c59b9862f469f896387247ae";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            py-aiger-bv
            pkgs.python310Packages.parsimonious
          ];
        };

        py-aiger-discrete = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_discrete";
          version = "0.1.10";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "946999bed701458e0678680ed0bac9b49305cef3712c313344961c5d05905a65";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            py-aiger-bv
            py-aiger-ptltl
            pkgs.python310Packages.pyrsistent
            pkgs.python310Packages.funcy
            mdd
          ];
        };

        py-aiger-cnf = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_cnf";
          version = "5.0.8";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "ccda9b726d001e485b0c40f47024a601332cb6e37a45f8fbe69306c853a64eac";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            pkgs.python310Packages.bidict
            pkgs.python310Packages.funcy
          ];
        };

        py-aiger-sat = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_sat";
          version = "3.0.7";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "301bf572ff67b14bb0121fa74a838219c6867506949206d462568e1c55e7ddbb";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            py-aiger-bv
            py-aiger-cnf
            pkgs.python310Packages.python-sat
          ];
        };


        py-aiger-coins = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_coins";
          version = "3.3.7";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "f6a3ae482bb73b6798bf1fd5c891dff59c0deda9d0e3b43cc3b223e2cd5051d8";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            py-aiger-bv
            py-aiger-discrete
            py-aiger-bdd
            mdd
            pkgs.python310Packages.attrs
            pkgs.python310Packages.numpy
            pkgs.python310Packages.bidict
            pkgs.python310Packages.funcy
          ];
        };

        py-aiger-dfa = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_dfa";
          version = "0.4.2";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "88f33c33f7da6bfab70f8d5290dc3fc318aa16732a8ff4cbc4575e281f375a87";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            py-aiger-bv
            py-aiger-ptltl
            dfa
            pkgs.python310Packages.attrs
            pkgs.python310Packages.bidict
            pkgs.python310Packages.funcy
            pkgs.python310Packages.pyrsistent
          ];
        };

        py-aiger-gridworld = pkgs.python310Packages.buildPythonPackage rec {
          pname = "py_aiger_gridworld";
          version = "0.4.3";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "a6fc53288d92d60c92378fbc0f20c8ef95b804caa84cacecd6418165b7a7a4b2";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            py-aiger-bv
            py-aiger-discrete
            pkgs.python310Packages.attrs
            pkgs.python310Packages.bidict
            pkgs.python310Packages.funcy
          ];
        };

        dfa-identify = pkgs.python310Packages.buildPythonPackage rec {
          pname = "dfa_identify";
          version = "3.13.0";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "4e701e25782d87ccf9c0d68f7d4bdac0f123d2bbed4c8dee1c0a2c706f5f6038";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            dfa
            pkgs.python310Packages.attrs
            pkgs.python310Packages.bidict
            pkgs.python310Packages.funcy
            pkgs.python310Packages.more-itertools
            pkgs.python310Packages.networkx
            pkgs.python310Packages.python-sat
          ];
        };

        diss = pkgs.python310Packages.buildPythonPackage rec {
          pname = "diss";
          version = "0.2.12";
          format = "wheel";
          src = pkgs.python310Packages.fetchPypi rec {
            inherit pname version format;
            sha256 = "d741a9aacc79a9e2969cd6e5d2ef3de95cd4b6255980b186a0897ea8d55c7428";
            dist = python;
            python = "py3";
          };
          propagatedBuildInputs = [
            py-aiger
            py-aiger-bdd
            py-aiger-coins
            py-aiger-gridworld
            py-aiger-ptltl
            py-aiger-dfa
            dfa
            dfa-identify
            pkgs.python310Packages.attrs
            pkgs.python310Packages.blessings
            pkgs.python310Packages.funcy
            pkgs.python310Packages.numpy
            pkgs.python310Packages.scipy
            pkgs.python310Packages.networkx
            pkgs.python310Packages.matplotlib
            pkgs.python310Packages.seaborn
            pkgs.python310Packages.tqdm
            pkgs.python310Packages.pydot
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
          py-aiger-bdd
          py-aiger-ptltl
          py-aiger-discrete
          py-aiger-cnf
          py-aiger-coins
          py-aiger-sat
          py-aiger-dfa
          py-aiger-gridworld
          dfa-identify
          diss
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
          pkgs.python310Packages.jupyterlab
          pkgs.graphviz
        ];
      };
    });
}
