FROM python:3.12-slim
WORKDIR /proyecto
COPY . /proyecto
CMD ["sh", "-c", "python scripts/run_demo.py && python scripts/alertas.py --fecha 2026-11-21 && python -m unittest discover -s tests -v"]
