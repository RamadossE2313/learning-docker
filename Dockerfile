#### Adding Base Image ####

## Stage: base

## adding base image depends on version of your application add it
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base 
WORKDIR /app  ## setting working director inside the container
## adding port 80 to listen http protocol
EXPOSE 80 
## adding port 443 to listen https protocol
EXPOSE 443

## Stage: build

## adding build image (Sdk image)
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build 
## setting working directory inside the container
WORKDIR /src
## copying project to current working directory, src folder
COPY ["SampleApiProject.csproj", "."]
## dotnet restore
RUN dotnet restore "./SampleApiProject.csproj" 
## copying all the files of the project to src folder
COPY . .
## setting working directory inside the container as src inside folder
WORKDIR "/src/."
## running dotnet build as release mode and output will be saved src/app/build folder
RUN dotnet build "SampleApiProject.csproj" -c Release -o /app/build

## Stage: publish

FROM build as publish
## running dotnet publish as release mode and output will be saved src/app/publish
RUN dotnet publish "SampleApiProject.csproj" -c Release -o /app/publish /p:UseAppHost=false

## Stage: run app
FROM base as final 
WORKDIR /app
## copying image from publish stage to working directory app folder
COPY --from=publish /app/publish .
## setting entry point
ENTRYPOINT ["dotnet", "SampleApiProject.dll"]