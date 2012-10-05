## Licensed to the Apache Software Foundation (ASF) under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  The ASF licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied.  See the License for the
## specific language governing permissions and limitations
## under the License.

from datetime import date
from django.db import models

from django.contrib.auth.models import User


class PigScript(models.Model):

    title = models.CharField(max_length=200, verbose_name='Title')
    text = models.TextField(blank=True, verbose_name='Text')
    creater = models.ForeignKey(User, verbose_name='User')
    date_created = models.DateField(verbose_name='Date', auto_now_add=True)
#    pig_script = models.FileField(
#        upload_to='pig_script/{t}'.format(t=date.today().isoformat()),
#        verbose_name='Script file')

    class Meta:
        ordering = ['-date_created']

    def __unicode__(self):
        return u'%s' % self.title
        
class Logs(models.Model):
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    status = models.CharField(max_length = 1)
    script_name = models.CharField(max_length = 50)

    class Meta:
        ordering = ['-start_time']

    def __unicode__(self):
        return u'%s' % self.script_name
