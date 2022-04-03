defmodule Servy.Utils.RequestHandlerSamples do
  def get_wildthings_request() do
"""
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
  end

  def get_bears_request() do
    """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
"""
  end

  def get_bigfoot_request() do
"""
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
  end
end
