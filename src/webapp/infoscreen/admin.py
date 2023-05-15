from django.contrib import admin
from django import forms
from .models import Office, Release
from django.db import models
from django.forms import TextInput, Textarea
from uuid import uuid4
from azure.storage.blob import BlobServiceClient
import os


class ReleaseAdminForm(forms.ModelForm):
    release_file = forms.FileField(required=False)
    release_title = forms.CharField(widget=forms.Textarea(attrs={'rows': 2}))
    release_body = forms.CharField(required=False, widget=forms.Textarea(attrs={'rows': 10}), help_text="Leave release body field empty if you want to show image only. Recommended size for image is at least 1440x810 px (16:9). Don't forget to choose image below!")
    
    class Meta:
        model = Release
        fields = '__all__'
            


class ReleaseAdmin(admin.ModelAdmin):
    form = ReleaseAdminForm
    list_display = ('release_title', 'release_owner_name', 'release_created', 'release_public_start', 'release_public_end', 'release_public_now')
    list_filter = ['release_owner_name']
    exclude = ('release_created', 'release_owner_name')

    formfield_overrides = {
        models.CharField: {'widget': TextInput(attrs={'size': '100'})},
        models.TextField: {'widget': Textarea(attrs={'rows': 10, 'cols': 100, 'maxlength': '700'})},
    }

    change_form_template = 'admin/release/change_form.html'

    def save_model(self, request, obj, form, change):

        file = form.cleaned_data['release_file']

        # Delete previous file from the Blob storage, if any
        if change:
            old_obj = self.model.objects.get(pk=obj.pk)
            old_file_url = str(old_obj.release_file)

            # Check if new file has been inserted
            if file != old_file_url:
                # Delete old file from Azure Blog storage if there is one
                try:
                    old_filename = "/".join(old_file_url.split("/")[-2:])
                    container_name = 'infoscreen'
                    block_blob_service = BlobServiceClient(account_url=os.getenv("AZURE_STORAGE_ACCOUNT_URL"), credential=os.getenv("AZURE_BLOB_CREDENTIAL"))
                    container_client = block_blob_service.get_container_client(container_name)
                    blob_client = container_client.delete_blob(blob=old_filename, delete_snapshots="include")
                    print("Deleted old file: " + old_filename)
                except:
                    print("File was already deleted or there weren't old file.")

                # New file to Azure Blog storage if there is any
                try:
                    filename = str(uuid4()) + "/" + file.name
                    container_name = 'infoscreen'
                    block_blob_service = BlobServiceClient(account_url=os.getenv("AZURE_STORAGE_ACCOUNT_URL"), credential=os.getenv("AZURE_BLOB_CREDENTIAL"))
                    container_client = block_blob_service.get_container_client(container_name)
                    blob_client = container_client.upload_blob(filename, file)
                    print("Uploaded new file: " + filename)

                    # Code to upload the file to Azure Blob storage and get the URL
                    file_url = blob_client.url
                    form.instance.file = file_url

                    obj.release_file = file_url
                except:
                    print("No files inserted")
                obj.save()
            else:
                obj.save()

        else:
            # Upload file to Azure Blog storage
            # Try to check if there is file at all
            try:
                filename = str(uuid4()) + "/" + file.name
                container_name = 'infoscreen'
                block_blob_service = BlobServiceClient(account_url=os.getenv("AZURE_STORAGE_ACCOUNT_URL"), credential=os.getenv("AZURE_BLOB_CREDENTIAL"))
                container_client = block_blob_service.get_container_client(container_name)
                blob_client = container_client.upload_blob(filename, file)

                # Code to upload the file to Azure Blob storage and get the URL
                file_url = blob_client.url
                form.instance.file = file_url

                obj.release_file = file_url
            except:
                pass
            obj.release_owner_name = request.user.username
            obj.save()


    def delete_model(self, request, obj):
        try:
            # Delete file from the Blob storage
            fileurl = str(obj.release_file)
            filename = "/".join(fileurl.split("/")[-2:])
            container_name = 'infoscreen'
            block_blob_service = BlobServiceClient(account_url=os.getenv("AZURE_STORAGE_ACCOUNT_URL"), credential=os.getenv("AZURE_BLOB_CREDENTIAL"))
            container_client = block_blob_service.get_container_client(container_name)
            blob_client = container_client.delete_blob(blob=filename, delete_snapshots="include")

        except:
            # File might be deleted already
            pass

        # Delete model from database
        obj.delete()

    def delete_queryset(self, request, queryset):
            
        # Cycle trough objects and delete from Blob storage
        for obj in queryset:
            try:
                fileurl = str(obj.release_file)
                filename = "/".join(fileurl.split("/")[-2:])
                container_name = 'infoscreen'
                block_blob_service = BlobServiceClient(account_url=os.getenv("AZURE_STORAGE_ACCOUNT_URL"), credential=os.getenv("AZURE_BLOB_CREDENTIAL"))
                container_client = block_blob_service.get_container_client(container_name)
                blob_client = container_client.delete_blob(blob=filename, delete_snapshots="include")
            except:
                # No file added or file already deleted
                pass

        # Delete whole queryset from Database
        queryset.delete()
    

    


admin.site.register(Release, ReleaseAdmin)
admin.site.register(Office)
