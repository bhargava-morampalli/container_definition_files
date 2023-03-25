# Container for building the environment
FROM condaforge/mambaforge:4.9.2-5 as conda

COPY conda-linux-64.lock .
## Use BuildKit's caching mounts to speed up builds.
##
## If you don't use BuildKit,
## add `&& conda clean -afy` at the end of this line.
RUN --mount=type=cache,target=/opt/conda/pkgs mamba create --copy -p /env --file conda-linux-64.lock
## Now add any local files from your repository.
## As an example, we add a Python package into
## the environment.
RUN conda run -p /env

# Distroless for execution
FROM gcr.io/distroless/base-debian11

## Copy over the conda environment from the previous stage.
## This must be located at the same location.
COPY --from=conda /env /env
## The command needs to be in […] notation as
## the distroless container doesn't contain
## a shell.
CMD [ \
  "/env/bin/gunicorn", "-b", "0.0.0.0:8000", "-k", "uvicorn.workers.UvicornWorker" \
]