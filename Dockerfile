# Dockerfile para a aplicação Flask

# 1. Escolha a imagem base do Python 3.13 ou superior (use a mais recente disponível no Docker Hub)
# Verifique as tags disponíveis em: https://hub.docker.com/_/python
# Usando -slim para uma imagem menor
FROM python:3.13-slim
# FROM python:3.12-slim # Use esta como alternativa se 3.13 não estiver estável/disponível

# 2. Define o diretório de trabalho dentro do container
WORKDIR /app

# 3. Define variáveis de ambiente úteis
# Impede o Python de criar arquivos .pyc
ENV PYTHONDONTWRITEBYTECODE 1

#Garante que logs apareçam imediatamente
ENV PYTHONUNBUFFERED 1    

# 4. Instala dependências do sistema: git (para clonar) e build-essential (caso alguma lib Python precise compilar C)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 5. Clone o seu repositório GitHub para dentro do diretório de trabalho (/app)
#    !!! SUBSTITUA PELA URL REAL DO SEU REPOSITÓRIO !!!
RUN git clone https://github.com/SergioSemprebom/FlaskFakePinterest.git .
# Se seu repositório for privado, você precisará configurar autenticação (SSH ou token), o que é mais complexo.

# 6. Instala as dependências Python
#    Assumindo que você tem um arquivo 'requirements.txt' no seu repositório
#    Se você usa Poetry (pyproject.toml), o comando será diferente (veja nota abaixo)
#COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# (Opcional - Se usar Poetry)
# RUN pip install --no-cache-dir poetry
# RUN poetry config virtualenvs.create false
# COPY pyproject.toml poetry.lock* ./
# RUN poetry install --no-dev --no-interaction --no-ansi

# 7. Expõe a porta que o Gunicorn (ou seu servidor WSGI) usará dentro do container
EXPOSE 8000

# 8. Define o comando para iniciar a aplicação quando o container rodar
#    !!! SUBSTITUA 'main:app' pelo nome_do_arquivo:nome_da_instancia_flask !!!
#    Ex: Se seu arquivo principal é fakepinterest/__init__.py e a app é 'app', use 'fakepinterest:app'
#    Ex: Se seu arquivo principal é main.py e a app é 'app', use 'main:app'
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main:app"]