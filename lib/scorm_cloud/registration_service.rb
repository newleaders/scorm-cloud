module ScormCloud
	class RegistrationService < BaseService

		not_implemented :get_registration_list_results,
			:get_launch_history, :get_launch_info, :reset_global_objectives,
			:update_learner_info, :test_registration_post_url

		def create_registration(course_id, reg_id, first_name, last_name, learner_id, options = {})
			params = options.merge({
				:courseid => course_id,
				:regid => reg_id,
				:fname => first_name,
				:lname => last_name,
				:learnerid => learner_id
			})
			xml = connection.call("rustici.registration.createRegistration", params)
			!xml.elements["/rsp/success"].nil?
		end

		def delete_registration(reg_id)
			xml = connection.call("rustici.registration.deleteRegistration", {:regid => reg_id })
			!xml.elements["/rsp/success"].nil?
		end

 		def get_registration_list(options = {})
			xml = connection.call("rustici.registration.getRegistrationList", options)
			xml.elements["/rsp/registrationlist"].map { |e| Registration.from_xml(e) }
		end

		def get_registration_result(reg_id, format="course")
			raise "Illegal format argument: #{format}" unless ["course","activity","full"].include?(format)
			xml = connection.call("rustici.registration.getRegistrationResult", { :regid => reg_id, :format => format })
			{ complete:  xml.elements["/rsp/registrationreport/complete"].text,
				success:   xml.elements["/rsp/registrationreport/success"].text,
				totaltime: xml.elements["/rsp/registrationreport/totaltime"].text,
				score:     xml.elements["/rsp/registrationreport/score"].text
			}
		end

		def launch(reg_id, redirect_url, options = {})
			params = options.merge({
				:regid => reg_id,
				:redirecturl => redirect_url
			})
			connection.launch_url("rustici.registration.launch", params)
		end

		def reset_registration(reg_id)
			xml = connection.call("rustici.registration.resetRegistration", {:regid => reg_id })
			!xml.elements["/rsp/success"].nil?
		end


	end
end
