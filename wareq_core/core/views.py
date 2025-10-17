from django.shortcuts import render

# Landing page
def index(request):
    return render(request, "core/index.html")

# (Optional) Add extra static pages later like "about", "contact", etc.
def about(request):
    return render(request, "core/about.html")

def pricing(request):
    return render(request, "core/pricing.html")

def features(request):
    return render(request, "core/features.html")

def integrations(request):
    return render(request, "core/integrations.html")

def api(request):
    return render(request, "core/api.html")