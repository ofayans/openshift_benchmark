require "docker"

class DockerInfoController < ApplicationController
  def get_docker_images
    Docker.url = Dockerserver.find_by(:id => params["docker_id"]).url
    raw_images = Docker::Image.all
    @images = []
    raw_images.each do |raw_image|
      image = {}
      image[:id] = raw_image.info["id"]
      image[:tag] = raw_image.info["RepoTags"][0].split(":")[0]
      @images << image
    end
  end
end
